# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# The Survey class represents a single survey or poll, and can contain multiple
# versions of the same survey.
class Survey < ActiveRecord::Base
  has_many :survey_versions, :dependent => :destroy
  belongs_to :survey_type
  belongs_to :site

  attr_accessible :name, :description, :survey_type_id, :site_id, :submit_button_text,
  :previous_page_text, :next_page_text, :js_required_fields_error, :invitation_percent,
  :invitation_interval, :invitation_text, :invitation_accept_button_text,
  :invitation_reject_button_text, :start_screen_button_text, :alarm, :alarm_notification_email, :holding_page,
  :show_numbers, :locale, :start_page_title, :invitation_preview_stylesheet, :survey_preview_stylesheet

  validates :name, :presence => true, :length => {:in => 1..255}, :uniqueness => true
  validates :description, :presence => true, :length => {:in => 1..65535}
  validates :site, presence: true

  validates :invitation_percent, presence: true, :format => { :with => /\A((100(\.0{1,2})?)|(\d{0,2})(\.\d{1,2})?)\z/ },
                                                 :numericality => {:greater_than => 0.01, :less_than_or_equal_to => 100}
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
  def create_new_major_version
    #get most recent version number
    new_maj_ver = self.survey_versions.maximum(:major).to_i + 1

    #create new version
    new_sv = self.survey_versions.build(:major=>new_maj_ver, :minor=>0, :published=>false, :locked => false, :archived => false)
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
#  id                       :integer(4)      not null, primary key
#  name                     :string(255)
#  description              :text
#  survey_type_id           :integer(4)
#  created_at               :datetime
#  updated_at               :datetime
#  archived                 :boolean(1)      default(FALSE)
#  site_id                  :integer(4)
#  submit_button_text       :string(255)
#  previous_page_text       :string(255)
#  next_page_text           :string(255)
#  js_required_fields_error :string(255)
#  invitation_percent       :integer(4)      not null, default(100)
#  invitation_interval      :integer(4)      not null, default(30)
#
