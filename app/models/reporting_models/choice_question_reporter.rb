class ChoiceQuestionReporter < QuestionReporter

  field :cq_id, type: Integer    # ChoiceQuestion id
  field :question, type: String

  # Total number of SurveyResponses for this ChoiceQuestion with values
  field :answered, type: Integer, default: 0

  # Total number of Answers chosen across ChoiceQuestion responses;
  # used for simple average count of number of responses (for multiselect)
  field :chosen, type: Integer, default: 0

  embeds_many :choice_answer_reporters
  embeds_many :choice_permutation_reporters

  def unanswered
    survey_version_responses - answered
  end

  def percent_answered
    @answered ||= (answered / survey_version_responses.to_f) * 100
  end

  def percent_unanswered
    100 - percent_answered
  end

  # average number of chosen Answer options across all answered questions
  def average_answers_chosen(precision = 1)
    (chosen / answered.to_f).round(precision)
  end

  def top_permutations(number = 10)
    choice_permutation_reporters.desc(:count).limit(number).map(&:permutation)
  end

  # Generate the data required to plot a chart for a choice question.
  #
  # @return [String] JSON data
  def generate_element_data(display_type, element_type)
    # build an array of data to convert to JSON
    [].tap do |data|
      case element_type
      when 'count_per_answer_option'
        data.push(*count_per_answer_option_data(display_type))
      else
        nil
      end
    end.to_json
  end

  def allows_multiple_selection
    choice_question.allows_multiple_selection
  end

  private

  # Generate data for the "Count per answer option" chart display. Creates an array
  # of Hash objects, which are required for Flot charting.
  #
  # @return [Array<Hash>] Hash of data for each answer option
  def count_per_answer_option_data(display_type)
    case display_type
    when "pie"
      choice_answer_reporters.map do |choice_answer_reporter|
        { label: choice_answer_reporter.text, data: choice_answer_reporter.count }
      end
    when "bar"
      choice_answer_reporters.each_with_index.map do |choice_answer_reporter, index|
        { data: [[index, choice_answer_reporter.count]], label: choice_answer_reporter.text }
      end
    else
      nil
    end
  end

  def survey
    @survey ||= Survey.find(s_id)
  end

  def survey_version
    @survey_version ||= SurveyVersion.find(sv_id)
  end

  def survey_version_responses
    @survey_version_responses = survey_version.survey_responses.count
  end

  def survey_element
    @survey_element ||= SurveyElement.find(se_id)
  end

  def choice_question
    @choice_question = ChoiceQuestion.find(cq_id)
  end
end
