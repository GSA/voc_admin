require 'spec_helper'

describe MatrixQuestionsController do
  include Authlogic::TestCase
  
  before do
    activate_authlogic
    UserSession.create User.create(:email => "jalvarado@ctacorp.com", :password => "password", :password_confirmation => "password", :f_name => "juan", :l_name => "alvarado")
    ExecutionTrigger.find_or_create_by_name("Test") do |et|
      et.id = 1
    end
  end
  
  let(:survey) { create :survey }
  let(:survey_version) { survey.survey_versions.first }

  let(:valid_attributes) do
    {
      "matrix_question"=> {
        "question_content_attributes"=> {
          "required"=>"false", 
          "statement"=>"Test Matrix Question"
        }, # Question Content Attributes
        "choice_questions_attributes"=> {
          "0"=>{
            "question_content_attributes"=>{
              "required"=>"false", 
              "_destroy"=>"false", 
              "statement"=>"Sub Question 1"
            } # sub-question 1
          }, 
          "1354020964815"=>{
            "question_content_attributes"=>{
              "required"=>"false", 
              "_destroy"=>"false", 
              "statement"=>"Sub Question 2"
            }
          } # sub-question 2
        }, # Choice Question Attributes
        "survey_element_attributes"=>{
          "page_id"=> survey_version.pages.first.id
        } # survey_element_attributes
      }, # matrix_question
      "choice_answer_attributes"=>{
        "0"=>{"answer"=>"answer 1"}, 
        "1"=>{"answer"=>"answer 2"}, 
        "2"=>{"answer"=>"answer 3"}, 
        "3"=>{"answer"=>""}
      }, # choice answer attributes
      "survey_id" => survey.id,
      "survey_version_id" => survey_version.id
    }
  end

  let(:matrix_question) do
    q = survey_version.matrix_questions.build(
      "question_content_attributes"=> {
        "required"=>"false", 
        "statement"=>"Test Matrix Question",
        "survey_version_id" => survey_version.id
      }, # Question Content Attributes
      "choice_questions_attributes"=> {
        "0"=>{
          "question_content_attributes"=>{
            "required"=>"false", 
            "_destroy"=>"false", 
            "statement"=>"Sub Question 1",
            "matrix_statement" => "Test Matrix Question"
          }, 
          "answer_type" => "radio",
          "choice_answers_attributes" => {
            "0" => { "answer" => "answer1" }
          }
        }, # sub-question 1
        "1354020964815"=>{
          "question_content_attributes"=>{
            "required"=>"false", 
            "_destroy"=>"false", 
            "statement"=>"Sub Question 2",
            "matrix_statement" => "Test Matrix Question"
          },
          "answer_type" => "radio",
          "choice_answers_attributes" => {
            "0" => { "answer" => "answer1" }
          }
        } # sub-question 2
      }, # Choice Question Attributes
      "survey_element_attributes"=>{
        "page_id"=> survey_version.pages.first.id,
        "survey_version_id" => survey_version.id
      } # survey_element_attributes
    )
    
    q.tap { |mq| mq.save!}
  end
  
  context 'remove_sub_question_display_field_and_rules' do
    it 'should delete the subquestion display field' do
      matrix_question
      question_attributes = {
        :question_content_attributes=>{
          :required=>"false", 
          :_destroy=>"false", 
          :statement=>"Sub Question 1",
          :matrix_statement => "Test Matrix Question"
        }, 
        :answer_type => "radio",
        :choice_answers_attributes => {
          "0" => { "answer" => "answer1" }
        }
      }
      
      DisplayField.count.should == 2
      Rule.count.should == 2
      
      expect {
        MatrixQuestionsController.new.send(:remove_sub_question_display_field_and_rules, matrix_question, question_attributes)
      }.to change {DisplayField.count}.by(-1)
    end
    
    it 'should delete the subquestion rule' do
      matrix_question
      question_attributes = {
        :question_content_attributes=>{
          :required=>"false", 
          :_destroy=>"false", 
          :statement=>"Sub Question 1",
          :matrix_statement => "Test Matrix Question"
        }, 
        :answer_type => "radio",
        :choice_answers_attributes => {
          "0" => { "answer" => "answer1" }
        }
      }
      
      DisplayField.count.should == 2
      Rule.count.should == 2
      
      expect {
        MatrixQuestionsController.new.send(:remove_sub_question_display_field_and_rules, matrix_question, question_attributes)
      }.to change {Rule.count}.by(-1)      
    end
  end
  
  context 'new' do
    # GET /matrix_questions/new
    it 'should assign a new matrix question to @matrix_question' do
      get :new, survey_id: survey.id, survey_version_id: survey_version.id

      assigns(:matrix_question).should_not be_nil
    end

    it 'should render the new template' do
      get :new, survey_id: survey.id, survey_version_id: survey_version.id

      response.should render_template(:new)
    end  
  end # GET matrix_questions/new
  
  context 'create' do
    it 'should create a new matrix question with valid attributes' do
      expect {
        post :create, valid_attributes
      }.to change{MatrixQuestion.count}.by(1)
    end
    
    it 'should not create a new matrix question with invalid attributes' do
      invalid_attributes = valid_attributes
      invalid_attributes["matrix_question"]["question_content_attributes"]["statement"] = nil
      
      expect {
        post :create, invalid_attributes
      }.to_not change{MatrixQuestion.count}
    end
    
    it 'should create the default DisplayField and Rule' do
      QuestionContentObserver.instance.should_receive(:after_create).exactly(3) # once for the matrix question, and each of the sub questions
      post :create, valid_attributes
    end
  end # POST matrix_questions/
  
  context 'edit' do
    it 'should render the edit template' do      
      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: matrix_question.id
      
      response.should render_template(:edit)
    end
    
    it 'should assign @matrix_question' do
      get :edit, survey_id: survey.id, survey_version_id: survey_version.id, id: matrix_question.id
      
      assigns(:matrix_question).should_not be_nil
    end
  end # GET /matrix_questions/:id/edit
  
  
  context 'update' do
    it 'should update the matrix_question' do
      updated_attributes = {
        "question_content_attributes" => {
          "statement" => "Updated Statement"
        },
        "choice_questions_attributes"=> {
          "0"=>{
            "question_content_attributes"=>{
              "required"=>"false", 
              "_destroy"=>"false", 
              "statement"=>"Sub Question 1"
            }, 
            "answer_type" => "radio",
            "choice_answers_attributes" => {
              "0" => { "answer" => "answer1" }
            }
          }, # sub-question 1
          "1354020964815"=>{
            "question_content_attributes"=>{
              "required"=>"false", 
              "_destroy"=>"false", 
              "statement"=>"Sub Question 2"
            },
            "answer_type" => "radio",
            "choice_answers_attributes" => {
              "0" => { "answer" => "answer1" }
            }
          } # sub-question 2
        }
      }
      
      answer_attributes = {
        "0" => {
          "answer" => "answer 1"
        }
      }
      
      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: matrix_question.id, 
        matrix_question: updated_attributes,
        choice_answer_attributes: answer_attributes
      
      matrix_question.reload.statement.should == "Updated Statement"
    end
    
    it 'should update the display field names when the matrix statement is updated' do
      updated_attributes = {
        "question_content_attributes" => {
          "statement" => "Updated Statement"
        },
        "choice_questions_attributes"=> {
          "0"=>{
            "question_content_attributes"=>{
              "required"=>"false", 
              "_destroy"=>"false", 
              "statement"=>"Sub Question 1"
            }, 
            "answer_type" => "radio",
            "choice_answers_attributes" => {
              "0" => { "answer" => "answer1" }
            }
          }, # sub-question 1
          "1354020964815"=>{
            "question_content_attributes"=>{
              "required"=>"false", 
              "_destroy"=>"false", 
              "statement"=>"Sub Question 2"
            },
            "answer_type" => "radio",
            "choice_answers_attributes" => {
              "0" => { "answer" => "answer1" }
            }
          } # sub-question 2
        }
      }
      
      answer_attributes = {
        "0" => {
          "answer" => "answer 1"
        }
      }
      
      QuestionContentObserver.instance.should_receive(:after_update)
      
      put :update, survey_id: survey.id, survey_version_id: survey_version.id, id: matrix_question.id, 
        matrix_question: updated_attributes,
        choice_answer_attributes: answer_attributes

    end
    
  end # PUT /matrix_questions/:id
  
  context 'destroy' do
    it 'should destroy the default rule and display field' do
      MatrixQuestionsController.any_instance.should_receive(:destroy_default_rule_and_display_field)
      
      delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: matrix_question.id
    end
    
    it 'should destroy the matrix question' do
      MatrixQuestionsController.any_instance.stub(:destroy_default_rule_and_display_field)
      matrix_question
      expect {
        delete :destroy, survey_id: survey.id, survey_version_id: survey_version.id, id: matrix_question.id  
      }.to change {MatrixQuestion.count}.by(-1)
      
    end
    
  end # DELETE /matrix_questions/:id
  
  context 'get_survey_and_survey_version'
  

  
  context 'destroy_default_rule_and_display_field'
end