class ChoiceQuestionReporter < QuestionReporter

  field :cq_id, type: Integer    # ChoiceQuestion id
  field :question, type: String

  # Total number of Answers chosen across ChoiceQuestion responses;
  # used for simple average count of number of responses (for multiselect)
  field :chosen, type: Integer, default: 0

  embeds_many :choice_answer_reporters
  embeds_many :choice_permutation_reporters

  def type
    @type ||= allows_multiple_selection ? "choice-multiple".to_sym : "choice-single".to_sym
  end

  # average number of chosen Answer options across all answered questions
  def average_answers_chosen(precision = 1)
    (chosen / answered.to_f).round(precision)
  end

  def top_permutations(number = 10)
    choice_permutation_reporters.desc(:count).limit(number).map(&:permutation)
  end

  def answered_for_date_range(start_date, end_date)
    return answered if start_date.nil? && end_date.nil?
    answered
  end

  # Generate the data required to plot a chart for a choice question. Creates an array
  # of Hash objects, which are required for Flot charting.
  #
  # @return [String] JSON data
  def generate_element_data(display_type, start_date = nil, end_date = nil)
    ordered_choice_answer_reporters = choice_answer_reporters.sort_by { |ocar| -ocar.count }

    case display_type
    when "pie"
      ordered_choice_answer_reporters.map do |choice_answer_reporter|
        { label: choice_answer_reporter.text, data: choice_answer_reporter.count }
      end.sort_by { |value| -value[:data] }
    when "bar"
      ordered_choice_answer_reporters.map.each_with_index do |choice_answer_reporter, index|
        { data: [[index, choice_answer_reporter.count]], label: choice_answer_reporter.text }
      end
    else
      nil
    end.to_json
  end

  def allows_multiple_selection
    choice_question.allows_multiple_selection
  end

  def self.generate_reporter(survey_version, choice_question)
    choice_question_reporter = ChoiceQuestionReporter.create!(cq_id: choice_question.id)
    self.set_common_fields(choice_question_reporter, survey_version, choice_question)
    choice_question_reporter.question = choice_question.question_content.statement

    choice_answer_hash = {}
    # initialize all answers with zero counts
    choice_question.choice_answers.each do |ca|
      car = choice_question_reporter.choice_answer_reporters.create!(ca_id: ca.id, text: ca.answer, count: 0)
      choice_answer_hash[ca.id.to_s] = car
    end

    choice_question.question_content.raw_responses.find_each do |raw_response|
      answer_values = raw_response.answer.split(",")

      permutations = choice_question_reporter.choice_permutation_reporters.where(ca_ids: raw_response.answer).first
      unless permutations
        values = answer_values.map do |av|
          next if choice_answer_hash[av].nil?
          choice_answer_hash[av].text
        end.compact.join(DisplayFieldValue::VALUE_DELIMITER)
        next if values.empty? || answer_values.size != values.size
        permutations = choice_question_reporter.choice_permutation_reporters.create(ca_ids: raw_response.answer, values: values)
      end
      permutations.inc(:count, 1)

      permutations.save
      choice_question_reporter.inc(:answered, 1)
      choice_question_reporter.inc(:chosen, answer_values.count)

      answer_values.each do |answer_value|
        answer = choice_answer_hash[answer_value]
        next unless answer
        answer.inc(:count, 1)
        answer.save
      end
    end
    choice_question_reporter.save
  end

  private

  def choice_question
    @choice_question ||= ChoiceQuestion.find(cq_id)
  end
end
