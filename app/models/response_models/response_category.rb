# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class ResponseCategory < ActiveRecord::Base
  belongs_to :category
end

# == Schema Information
#
# Table name: response_categories
#
#  id                  :integer          not null, primary key
#  category_id         :integer          not null
#  process_response_id :integer          not null
#  created_at          :datetime
#  updated_at          :datetime
#  survey_version_id   :integer          not null
#

