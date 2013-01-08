# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class ResponseCategory < ActiveRecord::Base
  belongs_to :category
end

# == Schema Information
# Schema version: 20110420181413
#
# Table name: response_categories
#
#  id                  :integer(4)      not null, primary key
#  category_id         :integer(4)      not null
#  process_response_id :integer(4)      not null
#  created_at          :datetime
#  updated_at          :datetime
#  survey_version_id   :integer(4)      not null
