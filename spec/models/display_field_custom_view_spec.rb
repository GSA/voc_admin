require 'spec_helper'

describe DisplayFieldCustomView do
  it { should validate_presence_of(:display_field) }
  it { should validate_presence_of(:custom_view) }

  it { should validate_uniqueness_of(:display_field_id).scoped_to(:custom_view_id) }
  it { should validate_uniqueness_of(:custom_view_id).scoped_to(:display_field_id) }
end
