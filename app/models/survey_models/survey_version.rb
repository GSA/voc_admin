require 'csv'

# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A SurveyVersion is a working copy of a survey.  Only one version may be published (and
# therefore collecting responses from the public site application) at a time.
class SurveyVersion < ActiveRecord::Base
  belongs_to :survey, :touch => true
  has_many :pages,           :dependent => :destroy
  has_many :survey_elements, :dependent => :destroy

  has_many :text_questions,     :through => :survey_elements, :source => :assetable, :source_type => "TextQuestion",    :dependent => :destroy
  has_many :choice_questions,   :through => :survey_elements, :source => :assetable, :source_type => "ChoiceQuestion",  :dependent => :destroy
  has_many :assets,             :through => :survey_elements, :source => :assetable, :source_type => "Asset",           :dependent => :destroy
  has_many :matrix_questions,   :through => :survey_elements, :source => :assetable, :source_type => "MatrixQuestion",  :dependent => :destroy

  has_many :rules,            :dependent => :destroy
  has_many :display_fields,   :dependent => :destroy
  has_many :survey_responses, :dependent => :destroy
  has_many :custom_views,     :dependent => :destroy

  attr_accessible :major, :minor, :notes, :survey_attributes, :version_number, :survey, :thank_you_page

  accepts_nested_attributes_for :survey

  validates :major, :presence => true, :numericality => true, :uniqueness => {:scope => [:survey_id, :minor]}
  validates :minor, :presence => true, :numericality => true, :uniqueness => {:scope => [:survey_id, :major]}
  validates :notes, :length => {:maximum => 65535}
  validates :survey, :presence => true

  # Scopes for partitioning survey versions
  scope :published, where(:published => true)
  scope :unpublished, where(:published => false)

  # these need updated to make sure the survey hasn't been archved
  scope :get_archived, where(:archived => true)
  scope :get_unarchived, where(:archived => false)

  # Add methods to access the name and description of a survey from a version instance
  delegate :name, :description, :to => :survey, :prefix => true

  # Create a CSV export of the survey responses and notify the requesting user by email
  # when the export has completed and is available for download.
  #
  # All search parameters, filters, and custom view options are respected in the export.
  #
  # @param [Hash] filter_params parameters for filtering the survey responses (Advanced Search, Simple Search, Custom Views)
  # @param [Integer] user_id ID for the user requesting the export
  def generate_responses_csv(filter_params, user_id)
    survey_responses = self.survey_responses.processed

    # use the simple search
    survey_responses = survey_responses.search(filter_params[:simple_search]) unless filter_params[:simple_search].blank?

    # use the advanced search filters
    unless filter_params[:search].blank?
      search = SurveyResponseSearch.new(filter_params[:search])

      survey_responses = search.search(survey_responses)
    end
    custom_view = nil
    if filter_params[:custom_view_id].blank?
      custom_view = self.custom_views.find_by_default(true)
    else
      # Use find_by_id in order to return nil if a custom view with the specified id
      # cannot be found instead of raising an error.
      custom_view = self.custom_views.find_by_id(filter_params[:custom_view_id])
    end

    # Apply the custom view to the survey responses
    custom_view = nil
    if filter_params[:custom_view_id].blank?
      custom_view = self.custom_views.find_by_default(true)
    else
      # Use find_by_id in order to return nil if a custom view with the specified id
      # cannot be found instead of raising an error.
      custom_view = self.custom_views.find_by_id(filter_params[:custom_view_id])
    end

    # Write the survey responses to a temporary CSV file which will be used to create the
    # Export instance.  The document will be copied to the correct location by paperclip
    # when the Export instance is created.
    file_name = "#{Time.now.strftime("%Y%m%d%H%M")}-#{self.survey.name[0..10]}-#{self.version_number}.csv"
    CSV.open("#{Rails.root}/tmp/#{file_name}", "wb") do |csv|

      unless custom_view.present?
        display_field_headers = self.display_fields.order("display_order asc").map(&:name)
      else
        display_field_headers = custom_view.ordered_display_fields.map(&:name)
      end
      csv << ["Date", "Page URL"].concat(display_field_headers)

      survey_responses.find_in_batches do |responses|
        responses.each do |response|
          if custom_view.present?
            response_record = response.display_field_values.where(:display_field_id => custom_view.ordered_display_fields.map(&:id)).includes(:display_field => :display_field_custom_views).order('display_field_custom_views.display_order ASC').map {|dfv| dfv.value.blank? ? '' : dfv.value.gsub("{%delim%}", ", ")}
          else
            response_record = response.display_field_values.includes(:display_field).order("display_fields.display_order asc").map {|dfv| dfv.value.blank? ? '' : dfv.value.gsub("{%delim%}", ", ")}
          end

          csv << [response.created_at, response.page_url].concat(response_record)
        end
      end
    end

    export_file = Export.create! :document => File.open("#{Rails.root}/tmp/#{file_name}")

    # Notify the user that the export has been successful and is available for download
    if export_file.persisted?
      ExportMailer.delay.export_download(User.find(user_id).email, export_file.id)
    end

    # Remove the temporary file used to create this export
    File.delete("#{Rails.root}/tmp/#{file_name}")
  end

  # Get all the SurveyElements that are Question elements.
  #
  # @return [Array<SurveyElement>] array containing all the question survey elements
  def question_elements
    self.survey_elements.where("assetable_type in (?)", %w(TextQuestion ChoiceQuestion MatrixQuestion)).order("element_order asc")
  end

  # Returns a collection of Assetable questions.
  #
  # @return [Array<Assetable>] collection of matching questions
  def questions
    self.question_elements.includes(:assetable).map(&:assetable)
  end

  # Get all the available question content ids for the survey version for use as Rule sources.
  #
  # @return [Array<Array<String, String>>] array of available question id and display text pair arrays for use as Rule sources
  def sources
    source_array = []
    self.questions.each do |q|
      if q.class == MatrixQuestion
        q.choice_questions.each {|cq| source_array << ["#{cq.question_content.id},QuestionContent", "#{q.question_content.statement}: #{cq.question_content.statement}(matrix answer)"]}
      else
        source_array << ["#{q.question_content.id},QuestionContent", "#{q.question_content.statement}(Question)"]
      end
    end
    source_array
  end

  # Used to present available question content ids for the survey version for use as Rule DB action targets.
  #
  # @return [Array<Array<String, String>>] an array of available question display text and id pair arrays for use as action targets
  def options_for_action_select
    source_array = []
    self.questions.each do |q|
      if q.class == MatrixQuestion
        q.choice_questions.each {|cq| source_array << ["#{q.question_content.statement}: #{cq.question_content.statement} response", "#{cq.question_content.id}"]}
      else
        source_array << ["#{q.question_content.statement} response", "#{q.question_content.id}"]
      end
    end
    source_array
  end

  # Gets the next available page number.
  #
  # @return [Integer] next available page number
  def next_page_number
    self.pages.count + 1
  end

  # Gets the next available SurveyElement order.
  #
  # @return [Integer] next available SurveyElement order
  def next_element_number
    self.survey_elements.count + 1
  end

  # Gets the version string in the format (major.minor).
  #
  # @return [String] version string
  def version_number
    "#{self.major}.#{self.minor}"
  end

  # Unpublish any previously published survey versions for the Survey and publish
  # this SurveyVersion instead.
  #
  # @return [Boolean] true if the publish succeeds, false otherwise
  def publish_me
    # Unpublish all other versions of the survey
    self.survey.survey_versions.published.update_all(:published => false)
    # Publish this version
    self.published = true
    self.locked = true
    self.save
  end

  # Unpublish the SurveyVersion.
  #
  # @return [Boolean] true if the SurveyVersion is successfully unpublished, false otherwise
  def unpublish_me
    self.published = false
    self.save
  end

  # Clone all elements of the SurveyVersion into a new minor version.
  #
  # All Pages, SurveyElements, DisplayFields, and Rules will be cloned into the new
  # SurveyVersion.
  #
  # @return [SurveyVersion] a new minor version of the SurveyVersion which is an exact copy of the cloned SurveyVersion
  def clone_me
    ActiveRecord::Base.transaction do
      survey = self.survey

      #get greatest minor version
      minor_version = self.survey.survey_versions.where(:major => self.major).order('survey_versions.minor desc').first.minor + 1
      new_sv = survey.survey_versions.build(self.attributes.merge(:minor => minor_version))
      new_sv.published = false
      new_sv.locked = false
      new_sv.save!

      #clone members
      ["pages", "survey_elements", "display_fields", "rules"].each do |member_name|
        self.send(member_name).each do |item|
          item.clone_me(new_sv)
        end
      end

      # Fix the next_page_ids for page level flow control
      new_sv.pages.where("pages.next_page_id is not null").all.select {|page| page.next_page.survey_version_id != new_sv.id}.each do |page|
        page.update_attributes(:next_page_id => new_sv.pages.find_by_clone_of_id(page.next_page_id).try(:id)) # Use try so that if something goes wrong and you can't find the correct page it will just blank out the flow control
      end

      new_sv
    end
  end
end

# == Schema Information
#
# Table name: survey_versions
#
#  id             :integer(4)      not null, primary key
#  survey_id      :integer(4)      not null
#  major          :integer(4)
#  minor          :integer(4)
#  published      :boolean(1)      default(FALSE)
#  locked         :boolean(1)      default(FALSE)
#  archived       :boolean(1)      default(FALSE)
#  notes          :text
#  created_at     :datetime
#  updated_at     :datetime
#  thank_you_page :text
#

