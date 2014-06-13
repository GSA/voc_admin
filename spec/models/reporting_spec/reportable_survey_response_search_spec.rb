require 'spec_helper'

describe ReportableSurveyResponseSearch, focus: true do
  let!(:responses) do
    [
      FactoryGirl.create(
        :reportable_survey_response,
        :created_at => Date.strptime('05/20/2014', '%m/%d/%Y'),
        :answers => {"1" => "Test 1"}
      ),
      FactoryGirl.create(
        :reportable_survey_response,
        :created_at => Date.strptime('05/21/2014', '%m/%d/%Y'),
        :answers => {"1" => "Not Test"}
      )
    ]
  end

  it 'returns all entries with no conditions' do
    response_search = ReportableSurveyResponseSearch.new({'criteria' => {}})
    expect(response_search.search.entries).to eq(responses)
  end

  it 'applies the passed in scope' do
    response_search = ReportableSurveyResponseSearch.new({'criteria' => {}})
    base_scope = ReportableSurveyResponse.where(survey_version_id: 1)
    excluded_response = FactoryGirl.create :reportable_survey_response,
      survey_version_id: 2

    expect(response_search.search(base_scope).entries).to_not include(excluded_response)
  end

  context 'exclude conditions' do
    it 'does not return matches' do
      response_search = new_response_search('1', 'equals', 'Not Test', '0')
      expect(response_search.search.entries).to_not include(responses.last)
    end

    it 'returns elements that do not match' do
      response_search = new_response_search('1', 'equals', 'Not Test', '0')
      expect(response_search.search.entries).to include(responses.first)
    end
  end

  context 'multiple criteria' do
    let!(:responses) do
      [
        FactoryGirl.create(
          :reportable_survey_response,
          :created_at => Date.strptime('05/20/2014', '%m/%d/%Y'),
          :answers => {"1" => "Not Test"}
        ),
        FactoryGirl.create(
          :reportable_survey_response,
          :created_at => Date.strptime('05/21/2014', '%m/%d/%Y'),
          :answers => {"1" => "Not Test"}
        )
      ]
    end

    it 'should combine multiple criteria' do
      criteria = {
        "criteria" => {
          "0" => {
            "include_exclude"=> '1',
            "display_field_id"=> '1',
            "condition"=> 'equals',
            "value"=> 'Not Test'
          },
          "1" => {
            "include_exclude" => '1',
            "display_field_id" => 'survey_responses.created_at',
            "condition" => 'greater_than',
            "value" => '05/20/2014',
            "join_clause" => "AND"
          }
        }
      }
      response_search = ReportableSurveyResponseSearch.new(criteria)
      expect(response_search.search.entries).to eq([responses.last])
    end

    it 'handles multiple exclusionary criteria' do
      criteria = {
        "criteria" => {
          "0" => {
            "include_exclude"=> '1',
            "display_field_id"=> '1',
            "condition"=> 'equals',
            "value"=> 'Not Test'
          },
          "1" => {
            "include_exclude" => '0',
            "display_field_id" => 'survey_responses.created_at',
            "condition" => 'greater_than',
            "value" => '05/20/2014',
            "join_clause" => "AND"
          }
        }
      }
      response_search = ReportableSurveyResponseSearch.new(criteria)
      expect(response_search.search.entries).to eq([responses.first])      
    end
  end

  context 'date conditions' do
    context '#equals' do
      it 'returns results for a specific date' do
        response_search = new_response_search('survey_responses.created_at', 'equals', '05/20/2014')
        expect(response_search.search.entries).to eq([responses.first])
      end

      it 'does not return results from other dates' do
        response_search = new_response_search('survey_responses.created_at', 'equals', '05/20/2014')
        expect(response_search.search.entries).to_not include(responses.last)
      end
    end

    context '#greater_than' do
      it 'returns results for later dates' do
        response_search = new_response_search('survey_responses.created_at', 'greater_than', '05/20/2014')
        expect(response_search.search.entries).to eq([responses.last])
      end

      it 'does not include the specified date' do
        response_search = new_response_search('survey_responses.created_at', 'greater_than', '05/20/2014')
        expect(response_search.search.entries).to_not include(responses.first)
      end
    end

    context '#less_than' do
      it 'returns results for earlier dates' do
        response_search = new_response_search('survey_responses.created_at', 'less_than', '05/21/2014')
        expect(response_search.search.entries).to eq([responses.first])
      end

      it 'does nto include the specified date' do
        response_search = new_response_search('survey_responses.created_at', 'less_than', '05/21/2014')
        expect(response_search.search.entries).to_not include(responses.last)
      end
    end
  end

  context 'String conditions' do
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

  def new_response_search(search_field, condition, value, include_exclude = '1')
    ReportableSurveyResponseSearch.new({
      "criteria"=> {
        "0"=> {
          "include_exclude"=> include_exclude,
          "display_field_id"=> search_field,
          "condition"=> condition,
          "value"=> value
        }
      }
    })
  end

end
