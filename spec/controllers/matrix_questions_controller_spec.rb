require 'spec_helper'

describe MatrixQuestionsController do
  include Authlogic::TestCase
  
  before do
    activate_authlogic
    UserSession.create User.create(:email => "jalvarado@ctacorp.com", :password => "password", :password_confirmation => "password", :f_name => "juan", :l_name => "alvarado")
  end
  
  context 'new' do
    # GET /matrix_questions/new
    it 'should assign a new matrix question to @matrix_question' do
      survey = create :survey
      survey_version = survey.survey_versions.first

      get :new, survey_id: survey.id, survey_version_id: survey_version.id

      assigns(:matrix_question).should_not be_nil
    end

    it 'should render the new template' do
      survey = create :survey
      survey_version = survey.survey_versions.first

      get :new, survey_id: survey.id, survey_version_id: survey_version.id

      response.should render_template(:new)
    end  
  end # GET matrix_questions/new
  
  context 'create' do
    it 'should create a new matrix question with valid attributes' do
      survey = create :survey
      survey_version = survey.survey_versions.first
      
      valid_attributes = {
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
      
      expect {
        post :create, valid_attributes
      }.to change{MatrixQuestion.count}.by(1)
    end
    
    it 'should not create a new matrix question with invalid attributes' do
      survey = create :survey
      survey_version = survey.survey_versions.first
      
      invalid_attributes = {
        "matrix_question"=> {
          "question_content_attributes"=> {
            "required"=>"false", 
            "statement"=>""
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
      
      expect {
        post :create, invalid_attributes
      }.to_not change{MatrixQuestion.count}
    end
  end # POST matrix_questions/
  
end