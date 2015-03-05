# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Join table linking a CustomView to DisplayFields.
class DisplayFieldCustomView < ActiveRecord::Base

  attr_accessible :display_field_id, :custom_view_id, :display_order, :custom_view, :display_field, :sort_order, :sort_direction

  belongs_to :display_field
  belongs_to :custom_view

  validates :display_field, presence: true
  validates :custom_view, presence: true
  validates :display_field_id, uniqueness: { scope: :custom_view_id }
  validates :custom_view_id, uniqueness: { scope: :display_field_id }
end

# == Schema Information
#
# Table name: display_field_custom_views
#
#  id               :integer(4)      not null, primary key
#  display_field_id :integer(4)
#  custom_view_id   :integer(4)
#  display_order    :integer(4)
#  sort_order		:integer(4)
#  sort_direction	:string(255)
#  created_at       :datetime
#  updated_at       :datetime
