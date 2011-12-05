require 'test_helper'

class DisplayFieldTextMultiTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: display_fields
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)     not null
#  type              :string(255)     not null
#  required          :boolean(1)      default(FALSE)
#  searchable        :boolean(1)      default(FALSE)
#  default_value     :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  display_order     :integer(4)      not null
#  survey_version_id :integer(4)
#  clone_of_id       :integer(4)
#

