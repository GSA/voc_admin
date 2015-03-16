# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# This class is not yet implemented.
class DisplayFieldCategory < ActiveRecord::Base
  belongs_to :display_field
  belongs_to :category
end

# == Schema Information
#
# Table name: display_field_categories
#
#  id               :integer          not null, primary key
#  display_field_id :integer          not null
#  category_id      :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#

