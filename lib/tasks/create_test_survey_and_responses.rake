
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

  # Add a new page to the survey
  page1 = version.pages.create! page_number: version.next_page_number

  # Add a text question to the survey
  text_question = TextQuestion.create! survey_element_attributes: {page_id: page1.id, survey_version_id: version.id}, question_content_attributes: {statement: "Text Question 1", flow_control: false, required: false}, answer_type: "area"

  puts text_question.inspect
  puts text_question.valid?
  puts text_question.errors unless text_question.valid?

  # Add a Multiple Choice Question
  choice_question = ChoiceQuestion.create! survey_element_attributes: {page_id: page1.id, survey_version_id: version.id}, question_content_attributes: {statement: "Choice Question 1 (Checkboxes)", flow_control: false}, 
    choice_answers_attributes: { '0' => {answer: "a", answer_order: 1, is_default: false}, '1' => {answer: "b", answer_order: 2, is_default: true}, '2' => { answer: "c", answer_order: 3, is_default: false}, '3' => {answer: "d", answer_order: 4, is_default: false} }, 
    answer_type: ChoiceAnswer::CHECKBOX, auto_next_page: false

  # publish the survey version
  version.publish_me

  # answer_array
  answer_array = File.open("/usr/share/dict/words").readlines

  # Create 10 answers to the survey
  100.times do
    response_params = {
      :page_url => "http://localhost:3000",
      :survey_version_id => version.id,
      :raw_responses_attributes => {
        "0" => {
          :question_content_id => text_question.reload.question_content.id,
          :answer => answer_array.sample.chomp
        },
        "1" => {
          :question_content_id => choice_question.reload.question_content.id,
          "answer" => [choice_question.reload.choice_answers.map(&:id).sample]
        }
      }
    }

    # submit the survey answers and process them
    SurveyResponse.process_response response_params, version.id
  end

end