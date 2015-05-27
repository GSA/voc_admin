# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# The Survey class represents a single survey or poll, and can contain multiple
# versions of the same survey.
class Survey < ActiveRecord::Base
  has_many :survey_versions, :dependent => :destroy
  belongs_to :survey_type
  belongs_to :site

  attr_accessor :created_by_id

  attr_accessible :name, :description, :survey_type_id, :site_id, :submit_button_text,
  :previous_page_text, :next_page_text, :js_required_fields_error, :invitation_percent,
  :invitation_interval, :invitation_text, :invitation_accept_button_text,
  :invitation_reject_button_text, :start_screen_button_text, :alarm, :alarm_notification_email, :holding_page,
  :show_numbers, :locale, :start_page_title, :invitation_preview_stylesheet, :survey_preview_stylesheet,
  :omb_expiration_date

  validates :name, :presence => true, :length => {:in => 1..255}, :uniqueness => true
  validates :description, :presence => true, :length => {:in => 1..65535}
  validates :site, presence: true

  validates :invitation_percent, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  validates :invitation_interval, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :alarm_notification_email, presence: true, :if => :alarm

  validates :js_required_fields_error, length: { maximum: 255 }
  validates :previous_page_text, length: { maximum: 255 }
  validates :next_page_text, length: { maximum: 255 }
  validates :submit_button_text, length: { maximum: 255 }

  scope :get_archived,            where(:archived => true)
  scope :get_unarchived,          where(:archived => false)
  scope :get_alpha_list,          order('surveys.name asc')
  scope :search,          ->(q = nil) { where("surveys.name like ?", "%#{q}%") unless q.blank?}

  default_scope where(:archived => false)

  after_create :create_new_major_version

  # Get the currently published version of the survey.
  #
  # @return [SurveyVersion, nil] the published survey version or nil if no survey version is currently published.
  def published_version
    self.survey_versions.where(:published => true).order('major desc, minor desc').first
  end

  # Get the newest version of the survey
  #
  # @return [SurveyVersion, nil] the survey version with the highest version number or nil if no versions exist.
  def newest_version
    self.survey_versions.order('major desc, minor desc').first
  end

  # Creates a new major version (x.0) of the survey.  Questions/Pages are not cloned into the
  # new major version.
  #
  # @return [SurveyVersion] the new empty SurveyVersion.
  def create_new_major_version(created_by_id = nil)
    #get most recent version number
    new_maj_ver = self.survey_versions.maximum(:major).to_i + 1

    #create new version
    new_sv = self.survey_versions.build(:major=>new_maj_ver, :minor=>0, :published=>false, :locked => false, :archived => false)
    new_sv.created_by_id = created_by_id || self.created_by_id
    new_sv.pages.build :page_number => 1, :survey_version => new_sv
    puts new_sv.pages.first.errors unless new_sv.valid?
    new_sv.tap {|sv| sv.save!}
  end

  # Creates a new minor version (1.x) of the Survey.  Questions/Pages are cloned into the new minor version.
  # The new minor version will be an exact copy of the source SurveyVersion.
  #
  # @param  [Integer] source_sv_id id of the SurveyVersion to clone
  # @return [SurveyVersion] the newly cloned SurveyVersion.
  def create_new_minor_version(source_sv_id = nil)
    source_sv = source_sv_id ? self.survey_versions.find(source_sv_id) : self.newest_version
    source_sv.clone_me
  end

   def import_survey_version(file, source_sv_id = nil)
    binding.pry
    file = file.read #File.read('../../Downloads/' + file.original_filename)
    data_hash = JSON.parse(file)
    new_maj_ver = self.survey_versions.maximum(:major).to_i + 1

    new_sv = self.survey_versions.build.tap do |sv|
      sv.major = new_maj_ver
      sv.minor = 0
      sv.published = false
      sv.locked  =  false
      sv.archived  =  false
      sv.notes  =  'Created via Import Process'
      sv.created_by_id = source_sv_id
    end
    new_sv.save!

    data_hash["pages"].each do |page|
      new_p = new_sv.pages.build( :page_number => page["page_number"], :survey_version => new_sv )
      new_p.save!
      page_array = []

      page["survey_elements"].each do |element|

        if element["assetable_type"] == "ChoiceQuestion"
          new_cq = new_sv.choice_questions.build(answer_type: element["answer_type"], auto_next_page: element["auto_next_page"])

          new_cq.build_survey_element.tap do |se|
            se.page = new_p
            se.survey_version = new_sv
          end

          new_cq.build_question_content.tap do |qc|
            qc.statement = element["statement"]
          end

          element["choice_answers"].each do |answer|
            new_cq.choice_answers.build(answer: answer["answer"])

          end

          new_cq.save!
          s_asset = new_cq.survey_element.id
        end

        if element["assetable_type"] == "TextQuestion"
          new_tq = new_sv.text_questions.build(answer_type: element["answer_type"], answer_size: element["answer_size"])

          new_tq.build_survey_element.tap do |se|
            se.page = new_p
            se.survey_version = new_sv
          end
          new_tq.build_question_content.tap do |tc|
            tc.statement = element["statement"]
          end
          new_tq.save!
          s_asset = new_tq.survey_element.id
        end

        if element["assetable_type"] == "MatrixQuestion"
          new_mq = new_sv.matrix_questions.new(survey_version_id: new_sv.id)
          # new_mq = new_sv.matrix_questions.build
          new_mq.build_survey_element.tap do |se|
            se.page = new_p
            se.survey_version = new_sv
          end
          new_mq.build_question_content.tap do |mc|
            mc.statement = element["statement"]
          end
          element["choice_questions"].each do |cq|
            new_cq = new_mq.choice_questions.build(answer_type: cq["answer_type"], auto_next_page: cq["auto_next_page"])
            new_cq.build_question_content.tap do |qc|
              qc.statement = cq["statement"]
            end
            cq["choice_answers"].each do |answer|
             new_cq.choice_answers.build(answer: answer["answer"])
            end
          end

          new_mq.save!
          s_asset = new_mq.survey_element.id
        end

        if element["assetable_type"] == "Asset"
          new_asset = new_sv.assets.build(snippet: element["snippet"])

          new_asset.build_survey_element.tap do |asset|
            asset.page = new_p
            asset.survey_version = new_sv
          end
          new_asset.save!
          s_asset = new_asset.survey_element.id
        end

        element_array = [new_p.id, element["element_order"], s_asset]
        page_array.push(element_array)
      end
      # page_array.each do |x|
      #   se = SurveyElement.find(x[2])
      #   se.element_order = x[1]
      #   # push page_number and possibly element["next_page"]into the array so we can set that in survey element.
      #   se.save
      # end
    end
  end

  def flushable_urls
    [
      "http://#{APP_CONFIG['public_host']}/surveys/#{id}",
      "http://#{APP_CONFIG['public_host']}/surveys/#{id}?version=#{published_version.version_number}",
      "http://#{APP_CONFIG['public_host']}/widget/#{id}/invitation.js"
    ]
  end
end

# == Schema Information
#
# Table name: surveys
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  description                   :text
#  survey_type_id                :integer
#  created_at                    :datetime
#  updated_at                    :datetime
#  archived                      :boolean          default(FALSE)
#  site_id                       :integer
#  submit_button_text            :string(255)
#  previous_page_text            :string(255)
#  next_page_text                :string(255)
#  js_required_fields_error      :string(255)
#  invitation_percent            :integer          default(100), not null
#  invitation_interval           :integer          default(30), not null
#  invitation_text               :text
#  invitation_accept_button_text :string(255)
#  invitation_reject_button_text :string(255)
#  alarm                         :boolean
#  alarm_notification_email      :string(255)
#  holding_page                  :text
#  show_numbers                  :boolean          default(TRUE)
#  locale                        :string(255)
#  start_screen_button_text      :string(255)
#  start_page_title              :string(255)
#  invitation_preview_stylesheet :string(255)
#  survey_preview_stylesheet     :string(255)
#

