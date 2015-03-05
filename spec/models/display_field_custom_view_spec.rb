# == Schema Information
#
# Table name: display_field_custom_views
#
#  id               :integer          not null, primary key
#  display_field_id :integer
#  custom_view_id   :integer
#  display_order    :integer
#  created_at       :datetime
#  updated_at       :datetime
#  sort_order       :integer
#  sort_direction   :string(255)
#

require 'spec_helper'

describe DisplayFieldCustomView do
  it { should validate_presence_of(:display_field) }
  it { should validate_presence_of(:custom_view) }

  it { should validate_uniqueness_of(:display_field_id).scoped_to(:custom_view_id) }
  it { should validate_uniqueness_of(:custom_view_id).scoped_to(:display_field_id) }
end
