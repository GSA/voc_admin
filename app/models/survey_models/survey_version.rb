require 'csv'

# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# A SurveyVersion is a working copy of a survey.  Only one version may be published (and
# therefore collecting responses from the public site application) at a time.
class SurveyVersion < ActiveRecord::Base
  include Redis::Objects
  include ResqueAsyncRunner
  @queue = :voc_csv

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

  has_many :dashboards,       :dependent => :destroy
  has_many :reports,          :dependent => :destroy
  has_many :survey_version_counts,    :dependent => :destroy

  attr_accessible :major, :minor, :notes, :survey_attributes, :version_number, :survey, :thank_you_page

  accepts_nested_attributes_for :survey

  validates :major, :presence => true, :numericality => true, :uniqueness => {:scope => [:survey_id, :minor]}
  validates :minor, :presence => true, :numericality => true, :uniqueness => {:scope => [:survey_id, :major]}
  validates :notes, :length => {:maximum => 65535}
  validates :survey, :presence => true

  # Scopes for partitioning survey versions
  scope :published, where(:published => true)
  scope :unpublished, where(:published => false)
  scope :locked, where(:locked => true)

  # these need updated to make sure the survey hasn't been archved
  scope :get_archived, where(:archived => true)
  scope :get_unarchived, where(:archived => false)

  # Add methods to access the name and description of a survey from a version instance
  delegate :name, :description, :to => :survey, :prefix => true

  hash_key :temp_visit_count
  hash_key :temp_invitation_count
  hash_key :temp_invitation_accepted_count

  def increment_temp_visit_count
    temp_visit_count.incr(today_string, 1)
  end

  def increment_temp_invitation_count
    temp_invitation_count.incr(today_string, 1)
  end

  def increment_temp_invitation_accepted_count
    temp_invitation_accepted_count.incr(today_string, 1)
  end

  def total_temp_visit_count
    @total_temp_visit_count ||= temp_visit_count.values.inject(0) {|result, element| result + element.to_i}
  end

  def total_temp_invitation_count
    @total_temp_invitation_count ||= temp_invitation_count.values.inject(0) {|result, element| result + element.to_i}
  end

  def total_temp_invitation_accepted_count
    @total_temp_invitation_accepted_count ||= temp_invitation_accepted_count.values.inject(0) {|result, element| result + element.to_i}
  end

  def total_visit_count
    @total_visit_count ||= survey_version_counts.sum(:visits) + total_temp_visit_count
  end

  def total_invitation_count
    @total_invitation_count ||= survey_version_counts.sum(:invitations) + total_temp_invitation_count
  end

  def total_invitation_accepted_count
    @total_invitation_accepted_count ||= survey_version_counts.sum(:invitations_accepted) + total_temp_invitation_accepted_count
  end

  def total_questions_asked
    reporter ? reporter.questions_asked : 0
  end

  def total_questions_skipped
    reporter ? reporter.questions_skipped : 0
  end

  # Update survey_version_counts
  def update_counts
    update_counts_for_attr(temp_visit_count, :visits)
    update_counts_for_attr(temp_invitation_count, :invitations)
    update_counts_for_attr(temp_invitation_accepted_count, :invitations_accepted)
    update_attribute(:counts_updated_at, Time.now)
  end

  # Increments visits by temporary recent_visits count
  def update_counts_for_attr(temp_count, attr_name)
    yesterday = today - 1.day
    temp_count.each do |date_string, count_string|
      date = Date.parse(date_string)
      count = count_string.to_i
      if count > 0
        svc = survey_version_counts.find_or_create_by_count_date(date)
        SurveyVersionCount.update_counters svc.id, attr_name => count
      end
      if date < yesterday
        temp_count.delete(date_string)
      else
        temp_count.incr(date_string, -count) if count > 0
      end
    end
  end

  NOSQL_BATCH = 1000

  def generate_responses_csv(filter_params, user_id)
    survey_response_query = ReportableSurveyResponse.where(survey_version_id: id)

    unless filter_params[:simple_search].blank?
      # TODO: come back to simple search later
    end

    unless filter_params[:search].blank?
      # TODO: come back to advanced search later
    end

    custom_view, sort_orders = nil
    if filter_params[:custom_view_id].blank?
      custom_view = custom_views.find_by_default(true)
    else
      # Use find_by_id in order to return nil if a custom view with the specified id
      # cannot be found instead of raising an error.
      custom_view = custom_views.find_by_id(filter_params[:custom_view_id])
    end

    # Ensures the responses are coming back in the proper order before batching
    ordered_columns = custom_view.ordered_display_fields if custom_view.present?
    ordered_columns ||= display_fields.order(:display_order)

    # Write the survey responses to a temporary CSV file which will be used to create the
    # Export instance.  The document will be copied to the correct location by paperclip
    # when the Export instance is created.
    file_name = "#{Time.now.strftime("%Y%m%d%H%M")}-#{survey.name[0..10]}-#{version_number}.csv"
    CSV.open("#{Rails.root}/tmp/#{file_name}", "wb") do |csv|
      csv << ["Date", "Page URL"].concat(ordered_columns.map(&:name))

      # For each response in batches...
      0.step(survey_response_query.count, SurveyVersion::NOSQL_BATCH) do |offset|
        survey_response_query.limit(SurveyVersion::NOSQL_BATCH).skip(offset).each do |response|

          # For each column we're looking to export...
          response_record = ordered_columns.map do |df|

            # Ask for the answer keyed on DisplayField id, fall back on default
            response_answer = response.answers[df.id.to_s].presence || df.default_value.to_s

            # Pass the entire array through a filter to break up multiple selection answers when done
          end.map! {|rr| rr.gsub("{%delim%}", ", ")}

          # Write the completed row to the CSV
          csv << [response.created_at, response.page_url].concat(response_record)
        end
      end
    end

    export_file = Export.create! :document => File.open("#{Rails.root}/tmp/#{file_name}")

    # Notify the user that the export has been successful and is available for download
    if export_file.persisted?
      resque_args = User.find(user_id).email, export_file.id

      begin
        Resque.enqueue(ExportMailer, *resque_args)
      rescue
        ResquedJob.create(class_name: "ExportMailer", job_arguments: resque_args)
      end
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

  def reporter
    @reporter ||= SurveyVersionReporter.where(:sv_id => id).first
  end

  def reporters
    @reporters ||= reporter ? reporter.question_reporters : []
  end

  def reload_reporters
    reporter.destroy
    @reporter = SurveyVersionReporter.find_or_create_reporter(id)
    reporter.update_reporter!
  end

  # generates a hash of page data that looks like
  # {
  #   345 => {
  #     :page_id => 345,
  #     :page_number => 1,
  #     :next_page_id => 346,
  #     :questions => [
  #       {
  #         :qc_id => 730,
  #         :questionable_type => "ChoiceQuestion",
  #         :questionable_id => 5,
  #         :flow_control => true,
  #         :flow_map => {
  #           "2013" => 346,
  #           "2014" => 348
  #         }
  #       }
  #     ]
  #   }
  # }
  def page_hash
    return @page_hash if @page_hash
    @page_hash = {}
    pages.each do |page|
      questions = []
      page.survey_elements.questions.each do |element|
        element.assetable.reload # for some reason this is necessary to get some question content
        if element.assetable_type == "MatrixQuestion"
          element.assetable.choice_questions.each {|cq| questions << question_hash(cq, true)}
        else
          questions << question_hash(element.assetable)
        end
      end
      @page_hash[page.id] = {page_id: page.id, page_number: page.page_number, next_page_id: page.next_page.try(:id), questions: questions}
    end
    @page_hash
  end

  def mark_reports_dirty!
    update_attribute :dirty_reports, true
  end

  def mark_reports_clean!
    update_attribute :dirty_reports, false
  end

  def run_rules_for_display_field(display_field)
    rules.includes(:actions).where(actions: { display_field_id: display_field.id })
        .each do |rule|
      puts "*"*100
      puts "Starting job for rule: #{rule.id}"
      puts "*"*100
      RuleJob.create id: rule.id
    end
  end

  private

  # hash of question used by pages_for_survey_version
  def question_hash(question, matrix_question = false)
    qc = question.question_content
    questionable_type = matrix_question ? "MatrixChoiceQuestion" : qc.questionable_type
    hash = {qc_id: qc.id, questionable_type: questionable_type, questionable_id: qc.questionable_id, flow_control: qc.flow_control?}
    if qc.flow_control?
      hash[:flow_map] = Hash[question.choice_answers.map {|ca| [ca.id.to_s, ca.next_page_id]}]
    end
    hash
  end

  def today
    Time.now.in_time_zone("Eastern Time (US & Canada)").to_date
  end

  def today_string
    today.strftime("%Y-%m-%d")
  end
end

# == Schema Information
#
# Table name: survey_versions
#
#  id                :integer(4)      not null, primary key
#  survey_id         :integer(4)      not null
#  major             :integer(4)
#  minor             :integer(4)
#  published         :boolean(1)      default(FALSE)
#  locked            :boolean(1)      default(FALSE)
#  archived          :boolean(1)      default(FALSE)
#  notes             :text
#  counts_updated_at :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  thank_you_page    :text
