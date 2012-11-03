require 'spec_helper'
include SurveyHelpers

describe SurveyResponse do
  before(:each) do
    @sr = SurveyResponse.new(
      :survey_version => mock_model(SurveyVersion),
      :display_field_values => [mock_model(DisplayFieldValue, :[]= => true, :save => true, :value => 'test')]
    )
  end

  it "should be valid" do
    @sr.should be_valid
  end

  it "should not be valid without a survey version" do
    @sr.survey_version = nil
    @sr.should_not be_valid
  end

  it "should get the next response from the new responses table"

  it "should add an entry to the new responses table after creation" do
    @sr.save!

    NewResponse.all.should have(1).response
  end

  it "should call queue_response when a response is created" do
    @sr.should_receive(:queue_for_processing).once.and_return(true)
    @sr.save!
  end

  it "should return all survey responses with a display field value like the provided search text" do
    # survey / version / page setups
    survey = create :survey
    version = survey.survey_versions.first
    page = version.pages.first || version.pages.create!(:page_number => 1)

    # create question
    question = build_text_question "text Question", version, page, 1

    # publish survey version
    version.publish_me

    # create survey responses
    sr = build_survey_response version, '123', { question => "test" }, true
    sr2 = build_survey_response version, '234', { question => "foo bar"}, true

    version.survey_responses.should have(2).responses

    sr.display_field_values.should have(1).dfv
    sr2.display_field_values.should have(1).dfv
    sr.display_field_values.first.update_attribute(:value, "This is a test")
    sr2.display_field_values.first.update_attribute(:value, "foo bar")

    version.survey_responses.search('test').should have(1).response
    version.survey_responses.search('').should have(2).responses
    version.survey_responses.search('should not match any').should have(0).responses
    version.survey_responses.search.should have(2).responses
  end

  context "order_by_display_field" do
    before(:each) do
      publish_survey_version
    end

    def build_eight_distinct_responses
      # create survey responses
      @sr1 = build_survey_response @v, '777', { @q1 => "y", @q2 => "a", @q3 => "2" }, true
      @sr2 = build_survey_response @v, '778', { @q1 => "y", @q2 => "b", @q3 => "2" }, true
      @sr3 = build_survey_response @v, '779', { @q1 => "z", @q2 => "a", @q3 => "2" }, true
      @sr4 = build_survey_response @v, '780', { @q1 => "z", @q2 => "b", @q3 => "2" }, true
      @sr5 = build_survey_response @v, '781', { @q1 => "y", @q2 => "a", @q3 => "1" }, true
      @sr6 = build_survey_response @v, '782', { @q1 => "y", @q2 => "b", @q3 => "1" }, true
      @sr7 = build_survey_response @v, '783', { @q1 => "z", @q2 => "a", @q3 => "1" }, true
      @sr8 = build_survey_response @v, '784', { @q1 => "z", @q2 => "b", @q3 => "1" }, true
    end

    def build_three_simple_responses
      @sr1 = build_survey_response @v, '101', { @q1 => "c", @q2 => "a", @q3 => "2" }, true
      @sr2 = build_survey_response @v, '102', { @q1 => "a", @q2 => "b", @q3 => "2" }, true
      @sr3 = build_survey_response @v, '103', { @q1 => "b", @q2 => "a", @q3 => "2" }, true
    end

    it 'should return table order without params' do
      build_three_simple_responses

      relation = SurveyResponse.order_by_display_field(nil, nil)

      relation.map{|r| r.client_id}.should eq(['101', '102', '103'])
    end

    it 'should correctly order by a single column' do
      build_three_simple_responses

      df_id = @sr1.display_field_values.first.display_field_id

      relation = SurveyResponse.order_by_display_field(df_id, 'asc')

      relation.map{|r| r.client_id}.should eq(['102', '103', '101'])
    end

    it 'should correctly order three levels deep' do
      build_eight_distinct_responses

      # pull back the display field ids
      df_ids = @sr1.display_field_values.map {|dfv| dfv.display_field_id}

      # pass in the second (a), third (a), then first (a) columns for sort ordering
      relation = SurveyResponse.order_by_display_field([1, 2, 0].map{ |x| df_ids[x] }, ['asc','asc','asc'] )

      # verified by spreadsheet!  so it's legit.
      relation.map{|r| r.client_id}.should eq(['781', '783', '777', '779', '782', '784', '778', '780'])

      # pass in the third (a), first (d), then second (d) columns for sort ordering
      relation = SurveyResponse.order_by_display_field([2, 0, 1].map{ |x| df_ids[x] }, ['asc','desc','desc'] )

      # verified by spreadsheet!  just happens to be reverse table order.
      relation.map{|r| r.client_id}.should eq(['784', '783', '782', '781', '780', '779', '778', '777'])
    end
  end
end