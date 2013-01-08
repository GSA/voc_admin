# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class DisplayFieldCategory < ActiveRecord::Base
  belongs_to :display_field
  belongs_to :category
end

# == Schema Information
# Schema version: 20110420181413
#
# Table name: display_field_categories
#
#  id               :integer(4)      not null, primary key
#  display_field_id :integer(4)      not null
#  category_id      :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
