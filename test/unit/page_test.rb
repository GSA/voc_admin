require 'test_helper'

class PageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: pages
#
#  id                :integer(4)      not null, primary key
#  page_number       :integer(4)
#  survey_version_id :integer(4)
#  style_id          :integer(4)
#  created_at        :datetime
#  updated_at        :datetime
#  clone_of_id       :integer(4)
#  next_page_id      :integer(4)
#

