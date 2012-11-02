require 'spec_helper'

describe QuestionContentObserver do

  context "after_create" do
    context "matrix_question? returns true" do
      it "does not call create_default_display_field" do
        QuestionContentObserver.should_not_receive(:create_default_display_field)

        QuestionContentObserver.instance.after_create mock_model(QuestionContent, matrix_question?: true)
      end

      it "does not call create_default_rule" do
        QuestionContentObserver.should_not_receive(:create_default_rule)

        QuestionContentObserver.instance.after_create mock_model(QuestionContent, matrix_question?: true)
      end
    end # matrix_question? == true

    context "skip_observer returns true" do
      it "does not call create_default_display_field" do
        QuestionContentObserver.should_not_receive(:create_default_display_field)

        QuestionContentObserver.instance.after_create mock_model(QuestionContent, matrix_question?: true, skip_observer: true)
      end

      it "does not call create_default_rule" do
        QuestionContentObserver.should_not_receive(:create_default_rule)

        QuestionContentObserver.instance.after_create mock_model(QuestionContent, matrix_question?: true, skip_observer: true)
      end      
    end # skip_observer == true

    context "question_content.questionable_type == ChoiceQuestion && question_content.questionable.matrix_question" do
      it 'sets the name to ("#{question_content.matrix_statement}: " + name) when true' do
        qc = mock_model(QuestionContent, matrix_question?: false, skip_observer: false, statement: "Rspec Test Statement", questionable_type: "ChoiceQuestion", matrix_statement: "Matrix Statement")
        qc.stub_chain(:questionable, :matrix_question).and_return(true)
        statement = "#{qc.matrix_statement}: " + qc.statement

        QuestionContentObserver.instance.should_receive(:create_default_display_field).with(qc, statement).and_return mock_model(DisplayField, present?: true)

        QuestionContentObserver.instance.stub(:create_default_rule).and_return mock_model(Rule, present?: true)

        QuestionContentObserver.instance.after_create(qc)
      end

      it "sets the name to question_content.statement when false" do
        qc = mock_model(QuestionContent, matrix_question?: false, skip_observer: false, statement: "Rspec Test Statement")

        QuestionContentObserver.instance.should_receive(:create_default_display_field).with(qc, qc.statement).and_return mock_model(DisplayField, present?: true)

        QuestionContentObserver.instance.stub(:create_default_rule).and_return mock_model(Rule, present?: true)

        QuestionContentObserver.instance.after_create(qc)       
      end
    end # question_content.questionable_type == ChoiceQuestion && question_content.questionable.matrix_question

    context "create_default_display_field" do
      it "should call DisplayField.create!" do
        qc = mock_model QuestionContent
        qc.stub_chain(:survey_version, :display_fields, :count).and_return 0
        qc.stub_chain(:survey_version, :id).and_return 1

        DisplayField.should_receive(:create!).with({
          :name => "Rspec Test Statement",
          :required => false,
          :searchable => false,
          :default_value => "",
          :display_order => 1, 
          :survey_version_id => 1,
          :editable => false
        })

        QuestionContentObserver.instance.send :create_default_display_field, qc, "Rspec Test Statement"
      end
    end # create_default_display_field

    context "create_default_rule" do
      it "should call rule.create!" do
        rules_proxy = mock "rule association proxy", count: 0
        sv_proxy = mock "survey_version association proxy", rules: rules_proxy
        qc = mock_model(QuestionContent, survey_version: sv_proxy)
        df = mock_model(DisplayField, :id => 1016)

        rules_proxy.should_receive(:create!).with({
          :name=>"Rspec Test Statement", 
          :rule_order=>1, 
          :execution_trigger_ids=>[1], 
          :action_type=>"db", 
          :criteria_attributes=>[{:source_id=> qc.id, :source_type=>"QuestionContent", :conditional_id=>10, :value=>""}], 
          :actions_attributes=>[{:display_field_id=>df.id, :value_type=>"Response", :value=> qc.id.to_s}]
        })

        QuestionContentObserver.instance.send :create_default_rule, qc, df, "Rspec Test Statement"        
      end

    end # create_default_rule

    it "should raise ActiveRecord::Rollback if create_default_display_field returns nil" do
      QuestionContentObserver.instance.stub!(:create_default_display_field).and_return nil

      expect {
        QuestionContentObserver.instance.after_create mock_model(QuestionContent, matrix_question?: false, skip_observer: false)
      }.to raise_error(ActiveRecord::Rollback)
    end

    it "should raise ActiveRecord::Rollback if create_default_rule returns nil" do
      QuestionContentObserver.instance.stub!(:create_default_display_field).and_return mock_model(DisplayField, present?: true)

      QuestionContentObserver.instance.stub!(:create_default_rule).and_return nil

      expect { QuestionContentObserver.instance.after_create mock_model(QuestionContent, matrix_question?: false, skip_observer: false) }.to raise_error(ActiveRecord::Rollback)
    end


  end # after_create

  # let(:question_content) do
  #   mock_model(QuestionContent,
  #     statement: "Rspec Test Content",
  #     questionable_type: "TextQuestion",
  #     skip_observer: false,
  #     survey_version: mock_model(SurveyVersion).as_null_object,
  #     matrix_question?: false
  #   )
  # end

  # before do
  #   DisplayFieldObserver.instance.stub(:after_create)
  #   question_content.stub_chain(:questionable, :matrix_question).and_return false
  #   question_content.stub_chain(:questionable, :errors, :add)   
  # end

  # context "create_default_display_field" do
  #   it "should create a new display field with the provided name" do
  #     name = question_content.statement
  #     question_content.survey_version.stub_chain(:display_fields, :count).and_return 0

  #     display_field = QuestionContentObserver.instance.send(:create_default_display_field, question_content, name)
  #     display_field.name.should == "Rspec Test Content"
  #   end

  #   it "should set the display_order to the next sequence" do
  #     name = question_content.statement
  #     question_content.survey_version.stub_chain(:display_fields, :count).and_return 0

  #     display_field = QuestionContentObserver.instance.send(:create_default_display_field, question_content, name)
  #     display_field.display_order.should == 1      
  #   end
  # end

  # context "after_create" do
  #   it "should call create_default_display_field" do
  #     QuestionContentObserver.instance.should_receive(:create_default_display_field).with(question_content, question_content.statement)
  #     QuestionContentObserver.instance.after_create(question_content)
  #   end

  #   it "creates a default rule" do
  #     display_field = mock_model DisplayField
  #     QuestionContentObserver.instance.stub(:create_default_display_field).and_return(display_field)
  #     question_content.survey_version.stub_chain(:rules, :count).and_return 0

  #     question_content

  #     QuestionContentObserver.instance.send(:create_default_rule, question_content, display_field, "Rspec Test Content")
  #   end

  #   it "raises ActiveRecord::Rollback if there is an error creating the default display field"

  #   it "raises ActiveRecord::Rollback if there is an error creating the default rule"

  #   it "adds an error to the questionable model if an exception was raised"

  #   context "questionable_type is MatrixQuestion" do
  #     it "does not create a default display field"

  #     it "does not create a default rule"
  #   end # Matrix Question

  #   context "questionable_type is ChoiceQuestion" do
  #     context "and is part of a matrix question" do
  #       it "prepends the matrix statement to the name of the display field"

  #       it "prepends the matrix statement to the name of the rule"

  #     end # Part of matrix question
  #   end # ChoiceQuestion 
  # end # after_create
end