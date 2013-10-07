class ChoiceQuestionReporter < QuestionReporter

  field :cq_id, type: Integer    # ChoiceQuestion id
  field :question, type: String

  # Total number of Answers chosen across ChoiceQuestion responses;
  # used for simple average count of number of responses (for multiselect)
  field :chosen, type: Integer, default: 0

  embeds_many :choice_answer_reporters
  embeds_many :choice_permutation_reporters

  def type
    :choice
  end

  # average number of chosen Answer options across all answered questions
  def average_answers_chosen(precision = 1)
    (chosen / answered.to_f).round(precision)
  end

  def top_permutations(number = 10)
    choice_permutation_reporters.desc(:count).limit(number).map(&:permutation)
  end

  # Generate the data required to plot a chart for a choice question. Creates an array
  # of Hash objects, which are required for Flot charting.
  #
  # @return [String] JSON data
  def generate_element_data(display_type)
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

  private

  def choice_question
    @choice_question = ChoiceQuestion.find(cq_id)
  end
end
