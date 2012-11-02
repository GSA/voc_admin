require 'spec_helper'

describe DisplayFieldCustomView do
  it { should validate_presence_of(:display_field) }
  it { should validate_presence_of(:custom_view) }

  it { should validate_uniqueness_of(:display_field_id).scoped_to(:custom_view_id) }
  it { should validate_uniqueness_of(:custom_view_id).scoped_to(:display_field_id) }
end

# == Schema Information
#
# Table name: display_field_custom_views
#
#  id               :integer(4)      not null, primary key
#  display_field_id :integer(4)
#  custom_view_id   :integer(4)
#  display_order    :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#

