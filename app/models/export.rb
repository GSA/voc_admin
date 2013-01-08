# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Defines a SurveyResponse CSV data Export file.
class Export < ActiveRecord::Base
  has_attached_file :document,
                    :processors => [],
                    :path => ":rails_root/exports/:filename",
                    :url  => "/exports/:access_token/download"

  before_validation :generate_access_token

  validates :access_token, presence: true, uniqueness: true, length: { maximum: 255 }
  validates_attachment_presence :document

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
#  id                    :integer(4)      not null, primary key
#  access_token          :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  document_file_name    :string(255)
#  document_content_type :string(255)
#  document_file_size    :integer(4)
#  document_updated_at   :datetime
