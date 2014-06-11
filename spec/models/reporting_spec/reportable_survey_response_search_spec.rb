require 'spec_helper'

describe ReportableSurveyResponseSearch, focus: true do

  context 'conditions' do
    let!(:responses) do
      [
        FactoryGirl.create(:reportable_survey_response, :answers => {"1" => "Test 1"}),
        FactoryGirl.create(:reportable_survey_response, :answers => {"1" => "Not Test"})
      ]
    end

    it '#equals' do
      response_search = new_response_search('1', 'equals', 'Test 1')
      expect(response_search.search.entries).to eq([responses.first])
    end

    it '#contains' do
      response_search = new_response_search('1', 'contains', 'Test')
      expect(response_search.search.entries).to eq(responses)
    end

    context '#beings_with' do
      it 'includes responses that begin with' do
        response_search = new_response_search('1', 'begins_with', 'Not')
        expect(response_search.search.entries).to eq([responses.last])
      end
    end

    context '#ends_with' do
      let(:response_search) { new_response_search('1', 'ends_with', 'Test') }

      it 'includes answers ending with' do
        expect(response_search.search.entries).to eq([responses.last])
      end
    end

    context '#less_than' do
      let(:response_search) { new_response_search('1', 'less_than', 'Not Test 1') }

      it 'does a lexicographical comparison on strings' do
        expect(response_search.search.entries).to eq([responses.last])
      end

      it 'does a lexicographical comparison based on letter order' do
        response_search = new_response_search('1', 'less_than', 'Not Tes')
        expect(response_search.search.entries).to be_empty
      end

      it 'does not include exact matches' do
        response_search = new_response_search('1', 'less_than', 'Not Test')
        expect(response_search.search.entries).to be_empty
      end
    end

    context '#greater_than' do
      it 'does a lexicographics comparison based on length' do
        response_search = new_response_search('1', 'greater_than', 'Not Test')
        expect(response_search.search.entries).to eq([responses.first])
      end

      it 'does not include exact matches' do
        response_search = new_response_search('1', 'greater_than', 'Not Test')
        expect(response_search.search.entries).to_not include(responses.last)
      end
    end

  end

  def new_response_search(search_field, condition, value)
    ReportableSurveyResponseSearch.new({
      "criteria"=> {
        "0"=> {
          "include_exclude"=>"1",
          "display_field_id"=> search_field,
          "condition"=> condition,
          "value"=> value
        }
      }
    })
  end

end
