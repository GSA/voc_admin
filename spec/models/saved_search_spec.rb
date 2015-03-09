require 'spec_helper'

describe SavedSearch do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:search_params) }
  it { should belong_to(:survey_version) }
end

# == Schema Information
#
# Table name: saved_searches
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  survey_version_id :integer
#  search_params     :text
#  created_at        :datetime
#  updated_at        :datetime
#
