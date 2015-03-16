require 'spec_helper'

describe SavedSearch do
  it 'has a valid factory' do
    FactoryGirl.build(:saved_search).should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:search_params) }
  it { should belong_to(:survey_version) }

  context '#query_params' do
    let(:saved_search) { FactoryGirl.build(:saved_search) }

    it 'returns a hash object' do
      saved_search.query_params.should be_a(Hash)
    end

    it 'return a hash of the parsed query string' do
      saved_search.query_params.should == {
        "survey_version_id"=>"324",
        "survey_id"=>"132",
        "search"=> {
          "criteria"=> {
            "0"=> {
              "include_exclude"=>"1",
              "display_field_id"=>"created_at",
              "condition"=>"equals",
              "value"=>"01/01/2015"
            }
          }
        }
      }
    end
  end
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
