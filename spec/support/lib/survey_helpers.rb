module SurveyHelpers

  def publish_survey_version
    # without this, Rules aren't created and DisplayFieldValues don't populate.
    @et = create(:execution_trigger, :id => 1, :name => 'add')

    # survey / version / page setups
    @s = create :survey
    @v = @s.survey_versions.first
    @p = @v.pages.first || @v.pages.create!(:page_number => 1)

    # create questions
    @q1 = build_text_question "alpha", @v, @p, 1
    @q2 = build_text_question "beta", @v, @p, 2
    @q3 = build_text_question "omega", @v, @p, 3

    # save and publish survey version
    @v.publish_me
  end

  # SurveyResponse-specific helpers
  def build_text_question(statement, version, page, order)
    q = TextQuestion.new
    q.build_question_content :statement => statement #, :question_number => order
    q.build_survey_element :survey_version => version, :page => page, :element_order => order
    q.answer_type = 'field'
    q.save!

    q
  end

  def build_survey_response(version, client, questions_answers, process_rules)
    sr = SurveyResponse.new :survey_version => version, :client_id => client, :status_id => 1, :worker_name => nil

    questions_answers.each do |q, a|
      sr.raw_responses.build :client_id => client, :answer => a, :question_content => q.question_content, :status_id => 1, :survey_response => sr
    end

    # persist and process
    sr.save!
    sr.process_me(1) if process_rules

    sr
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
end
