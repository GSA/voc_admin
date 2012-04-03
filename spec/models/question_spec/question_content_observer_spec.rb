require 'spec_helper'

describe QuestionContentObserver do
  before(:each) do
    DisplayFieldObserver.instance.stub(:after_create)
    @sv = mock_model(SurveyVersion)
  end

  context "when a question content is updated" do
    it "should update the display field name when a question is updated" do
      mock_field = mock_model(DisplayField)
      @sv.stub_chain(:display_fields, :find_by_name).and_return(mock_field)
      mock_content = mock_model(QuestionContent,
        :statement_changed? => true, 
        :statement_was => "Old DispalyField Name", 
        :survey_version => @sv, 
        :statement => "New DisplayField Name",
        :questionable_type => "TextQuestion"
      )
      
      mock_field.should_receive(:update_attributes).with(:name => "New DisplayField Name").once
      
      QuestionContentObserver.instance.after_update(mock_content)
    end

    it "should not update the display field if the statement was not changed" do
      mock_field = mock_model(DisplayField)
      @sv.stub_chain(:display_fields, :find_by_name).and_return(mock_field)
      mock_field.should_not_receive :update_attributes
      QuestionContentObserver.instance.after_update(mock_model(QuestionContent, :statement_changed? => false))
    end

    it "should update the child question display fields for a matrix question" do
      mock_content = mock_model(QuestionContent,
        :statement_changed? => true, 
        :statement_was => "Old DispalyField Name", 
        :survey_version => @sv, 
        :statement => "New DisplayField Name",
        :questionable_type => "MatrixQuestion"
      )
      mock_question = mock_model(ChoiceQuestion)
      mock_question.stub_chain(:question_content, :statement).and_return("Test Question")
      
      mock_content.stub_chain(:questionable, :choice_questions, :includes).and_return([mock_question])

      mock_field = mock_model(DisplayField)
      @sv.stub_chain(:display_fields, :find_by_name).and_return(mock_field)

      mock_field.should_receive(:update_attributes).with(:name => "New DisplayField Name: Test Question")

      QuestionContentObserver.instance.after_update(mock_content)
    end

    it "should update the display field name correctly when updating a child question of a matrix question" do
       mock_content = mock_model(QuestionContent,
        :statement_changed? => true, 
        :statement_was => "Old DispalyField Name", 
        :survey_version => @sv, 
        :statement => "New DisplayField Name",
        :questionable_type => "ChoiceQuestion"
      )
      mock_content.stub_chain(:questionable, :matrix_question, :present?).and_return(true)
      
      mock_content.stub_chain(:questionable, :matrix_question, :question_content, :statement).and_return("Matrix Question Content")
      mock_question = mock_model(ChoiceQuestion)
      
      mock_content.stub_chain(:questionable, :choice_questions, :includes).and_return([mock_question])

      mock_field = mock_model(DisplayField)
      @sv.stub_chain(:display_fields, :find_by_name).and_return(mock_field)

      mock_field.should_receive(:update_attributes).with(:name => "Matrix Question Content: New DisplayField Name")

      QuestionContentObserver.instance.after_update(mock_content)     
    end
  end
  
  context "when a new question content is created" do
    it "should create a new display field for the question content" do
      sv = mock_model(SurveyVersion).as_null_object
      qc = mock_model(QuestionContent, :survey_version => sv, :questionable_type => "TextQuestion", :skip_observer => false, :statement => "Test")
      qc.stub_chain(:questionable, :matrix_question).and_return false
      sv.stub_chain(:rules, :create)
      sv.stub_chain(:rules, :count).and_return 0
      sv.stub_chain(:display_fields, :count).and_return 0

      rule = mock_model(Rule)
      rule.stub_chain(:errors, :any?).and_return(false)

      df = mock_model(DisplayFieldText)
      df.stub_chain(:errors, :any?).and_return(false)

      sv.stub_chain(:rules, :create).and_return(rule)

      DisplayFieldText.should_receive(:create!).and_return(df)

      QuestionContentObserver.instance.after_create(qc)
    end

    it "should create a new rule for the dispaly field" do
      sv = mock_model(SurveyVersion).as_null_object
      qc = mock_model(QuestionContent, :survey_version => sv, :questionable_type => "TextQuestion", :skip_observer => false, :statement => "Test")
      qc.stub_chain(:questionable, :matrix_question).and_return false
      sv.stub_chain(:rules, :create)
      sv.stub_chain(:rules, :count).and_return 0
      sv.stub_chain(:display_fields, :count).and_return 0

      rule = mock_model(Rule)
      rule.stub_chain(:errors, :any?).and_return(false)

      df = mock_model(DisplayFieldText)
      df.stub_chain(:errors, :any?).and_return(false)
      DisplayFieldText.stub(:create).and_return(df)
      #sv.stub_chain(:rules, :create).and_return(rule)

      sv.rules.should_receive(:create).and_return(rule)

      QuestionContentObserver.instance.after_create(qc)
    end

    it "should not create a new display field for a matrix question" do
      qc = mock_model(QuestionContent, :survey_version => mock_model(SurveyVersion), :questionable_type => "MatrixQuestion")

      DisplayField.should_not_receive(:create)
      QuestionContentObserver.instance.after_create(qc)
    end

    it "should not create a new rule for a matrix question" do
      qc = mock_model(QuestionContent, :survey_version => mock_model(SurveyVersion), :questionable_type => "MatrixQuestion")

      Rule.should_not_receive(:create)
      QuestionContentObserver.instance.after_create(qc)
    end

    it "should not create a new display field if :skip_observer is true" do
      qc = mock_model(QuestionContent, :survey_version => mock_model(SurveyVersion), :questionable_type => "TextQuestion", :skip_observer => true)

      DisplayField.should_not_receive(:create)
      QuestionContentObserver.instance.after_create(qc)
    end

    it "should not create a new rule if the :skip_observer is true" do
      qc = mock_model(QuestionContent, :survey_version => mock_model(SurveyVersion), :questionable_type => "TextQuestion", :skip_observer => true)

      Rule.should_not_receive(:create)
      QuestionContentObserver.instance.after_create(qc)
    end

    it "should raise ActiveRecord::Rollback if display field has errors" do
      qc = mock_model(QuestionContent, :survey_version => mock_model(SurveyVersion).as_null_object, :questionable_type => "TextQuestion", :skip_observer => false, :statement => "Test Question")
      qc.stub_chain(:questionable, :matrix_question).and_return(false)
      qc.stub_chain(:questionable, :errors, :add)
      df = mock_model(DisplayFieldText)
      df.stub_chain(:errors, :any?).and_return(true)
      DisplayFieldText.stub(:create).and_return(df)

      lambda { QuestionContentObserver.instance.after_create(qc) }.should raise_error(ActiveRecord::Rollback)
    end

    it "should raise ActiveRecord::Rollback if the rule has errors" do
      sv = mock_model(SurveyVersion).as_null_object
      qc = mock_model(QuestionContent, :survey_version => sv, :questionable_type => "TextQuestion", :skip_observer => false, :statement => "Test Question")
      qc.stub_chain(:questionable, :matrix_question).and_return(false)
      qc.stub_chain(:questionable, :errors, :add)
      DisplayFieldText.stub(:create).and_return(mock_model(DisplayFieldText).as_null_object)
      rule = mock_model(Rule)
      rule.stub_chain(:errors, :any?).and_return(true)
      sv.stub_chain(:rules, :count).and_return 0
      sv.stub_chain(:display_fields, :count).and_return 0
      sv.stub_chain(:rules, :create).and_return(rule)

      lambda { QuestionContentObserver.instance.after_create(qc) }.should raise_error(ActiveRecord::Rollback)
    end
  end
end