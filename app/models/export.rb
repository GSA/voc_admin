# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Defines a SurveyResponse CSV data Export file.
class Export < ActiveRecord::Base
  belongs_to :survey_version
  # S3 credentials are read from config/aws.yml
  # S3 configuration options are set in environments/production.rb
  has_attached_file :document, processors: []

  before_validation :generate_access_token

  validates :access_token, presence: true, uniqueness: true, length: { maximum: 255 }
  validates_attachment :document, presence: true
  do_not_validate_attachment_file_type :document

  def self.active
    where("created_at >= ?", 25.hours.ago)
  end

  private

  # Generate a unique identifier.
  #
  # @return [String] a 128-character hex string unique identifier.
  def generate_access_token
    self.access_token = SecureRandom.hex(64)
  end
end

# == Schema Information
#
# Table name: exports
#
#  id                    :integer          not null, primary key
#  access_token          :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer
#  document_updated_at   :datetime
#  survey_version_id     :integer
#
