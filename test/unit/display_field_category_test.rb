require 'test_helper'

class DisplayFieldCategoriesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: display_field_categories
#
#  id               :integer(4)      not null, primary key
#  display_field_id :integer(4)      not null
#  category_id      :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
#

