
desc "Create a test survey and prepoulate with some test answers"
task :add_test_data => [:environment] do
  # Create a test site for the survey
  site = Site.find_or_create_by_name("Test Site created by rake task") do |s|
   s.url = "http://wwww.test-rake-survey.com"
   s.description = "Test site created by rake task"
  end

  # Create a new survey
  survey = Survey.create! name: "Test Survey Created by rake task on #{Time.now.to_s}", description: "Test Survey", survey_type_id: SurveyType::PAGE, archived: false, site_id: site.id

  version = survey.survey_versions.first

  # Get the auto-created first page of the survey
  page1 = version.pages.first

  # Add a text question to the survey
  text_question = TextQuestion.create! survey_element_attributes: {page_id: page1.id, survey_version_id: version.id}, question_content_attributes: {statement: "Text Question 1", flow_control: false, required: false}, answer_type: "area"

  puts text_question.inspect
  puts text_question.valid?
  puts text_question.errors unless text_question.valid?

  # Add a Multiple Choice Question
  choice_question = ChoiceQuestion.create! survey_element_attributes: {page_id: page1.id, survey_version_id: version.id}, question_content_attributes: {statement: "Choice Question 1 (Checkboxes)", flow_control: false},
    choice_answers_attributes: { '0' => {answer: "a", answer_order: 1, is_default: false}, '1' => {answer: "b", answer_order: 2, is_default: true}, '2' => { answer: "c", answer_order: 3, is_default: false}, '3' => {answer: "d", answer_order: 4, is_default: false} },
    answer_type: ChoiceAnswer::CHECKBOX, auto_next_page: false

  # Add a Matrix Question
  matrix_question = MatrixQuestion.create! survey_element_attributes: { page_id: page1.id, survey_version_id: version.id}, survey_version_id: version.id, question_content_attributes: { statement: "Matrix Question 1", flow_control: false, required: false},
    choice_questions_attributes: {
      "0" => { question_content_attributes: { required: false, _destroy: false, statement: "Sub-Question 1", matrix_statement: "Matrix Question 1"}, answer_type: ChoiceAnswer::RADIO, choice_answers_attributes: { "0" => {answer: "answer 1"}, "1" => { answer: "answer 2"}, "2" => {answer: "answer 3"}, "3" => {"answer" => "answer 4"}} },
      "1" => { question_content_attributes: {required: false, _destroy: false, statement: "Sub-Question 2", matrix_statement: "Matrix Question 1"}, answer_type: ChoiceAnswer::RADIO, choice_answers_attributes: { "0" => {answer: "answer 1"}, "1" => { answer: "answer 2"}, "2" => {answer: "answer 3"}, "3" => {"answer" => "answer 4"}} }
    }

  # publish the survey version
  version.publish_me

  # answer_array
  answer_array = File.open("/usr/share/dict/words").readlines

  # Create 10 answers to the survey
  100.times do
    response_params = {
      :page_url => "http://voc-staging-test.com/#{answer_array.sample.chomp}",
      :survey_version_id => version.id,
      :raw_responses_attributes => {
        "0" => {
          :question_content_id => text_question.reload.question_content.id,
          :answer => answer_array.sample.chomp
        },
        "1" => {
          :question_content_id => choice_question.reload.question_content.id,
          "answer" => (rand(2) == 1 ? [choice_question.reload.choice_answers.map(&:id).sample] : '')
        },
        "2" => {
          :question_content_id => matrix_question.reload.choice_questions.first.question_content.id,
          "answer" => matrix_question.choice_questions.first.choice_answers[rand(matrix_question.choice_questions.first.choice_answers.size - 1)]
        },
        "3" => {
          :question_content_id => matrix_question.reload.choice_questions.last.question_content.id,
          "answer" => matrix_question.choice_questions.last.choice_answers[rand(matrix_question.choice_questions.last.choice_answers.size - 1)]
        }
      }
    }

    # submit the survey answers and process them
    SurveyResponse.process_response response_params, version.id
  end

  version.reload.survey_responses.each do |sr|
    new_time = Time.at( (Time.now.to_f - (Time.now-5.days).to_f)*rand + (Time.now-5.days).to_f )
    sr.update_attribute :created_at, new_time
  end

end
