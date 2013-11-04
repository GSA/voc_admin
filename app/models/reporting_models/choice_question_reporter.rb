class ChoiceQuestionReporter < QuestionReporter
  include ActionView::Helpers::NumberHelper

  field :cq_id, type: Integer    # ChoiceQuestion id
  field :question, type: String

  # Total number of Answers chosen across ChoiceQuestion responses;
  # used for simple average count of number of responses (for multiselect)
  field :chosen, type: Integer, default: 0

  embeds_many :choice_question_days
  embeds_many :choice_answer_reporters
  embeds_many :choice_permutation_reporters
  index "choice_question_days.date" => 1

  def type
    @type ||= allows_multiple_selection ? "choice-multiple".to_sym : "choice-single".to_sym
  end

  # average number of chosen Answer options across all answered questions
  def average_answers_chosen_for_date_range(start_date, end_date, precision = 1)
    chosen_for_dates = chosen_for_date_range(start_date, end_date)
    answered_for_dates = answered_for_date_range(start_date, end_date)
    (chosen_for_dates / answered_for_dates.to_f).round(precision)
  end

  def top_permutations_for_date_range(start_date, end_date, number = 10)
    permutations = choice_permutation_reporters.map {|cqr| cqr.permutation_for_date_range(start_date, end_date)}
    permutations.sort_by {|p| -p.count}.first(number)
  end

  def answered_for_date_range(start_date, end_date)
    return answered if start_date.nil? && end_date.nil?
    val = days_for_date_range(start_date, end_date).sum(:answered)
    val.nil? ? 0 : val
  end

  def chosen_for_date_range(start_date, end_date)
    return chosen if start_date.nil? && end_date.nil?
    val = days_for_date_range(start_date, end_date).sum(:chosen)
    val.nil? ? 0 : val
  end

  def days_for_date_range(start_date, end_date)
    days = choice_question_days
    days = days.where(:date.gte => start_date.to_date) unless start_date.nil?
    days = days.where(:date.lte => end_date.to_date) unless end_date.nil?
    days
  end

  def ordered_choice_answer_reporters_for_date_range(start_date, end_date)
    cars = choice_answer_reporters.map {|car| [car.text, car.count_for_date_range(start_date, end_date)]}
    cars.sort_by { |car| -car[1] }
  end

  def choice_answers_str(start_date, end_date)
    answer_reporters = ordered_choice_answer_reporters_for_date_range(start_date, end_date)
    total_answered = answered_for_date_range(start_date, end_date)
    answer_array = answer_reporters.map do |car| 
      answer_percent = total_answered == 0 ? 0 : car[1] * 100.0 / total_answered
      answer_percent = number_to_percentage(answer_percent, precision: 2)
      "#{car[0]}: #{number_with_delimiter(car[1])} (#{answer_percent})"
    end
    answer_array.join(", ")
  end

  # Generate the data required to plot a chart for a choice question. Creates an array
  # of Hash objects, which are required for Flot charting.
  #
  # @return [String] JSON data
  def generate_element_data(display_type, start_date = nil, end_date = nil)
    case display_type
    when "pie"
      ordered_choice_answer_reporters_for_date_range(start_date, end_date).map do |car|
        [car[0], car[1]]
      end
    when "bar"
      ordered_choice_answer_reporters_for_date_range(start_date, end_date).map.each_with_index do |car, index|
        { data: [[index, car[1]]], label: car[0] }
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

    choice_question.question_content.raw_responses.unscoped.find_each do |raw_response|
      choice_question_reporter.add_raw_response(raw_response, choice_answer_hash)
    end
    choice_question_reporter.save
  end

  def add_raw_response(raw_response, choice_answer_hash)
    answer_values = raw_response.answer.split(",")
    date = raw_response.created_at.in_time_zone("Eastern Time (US & Canada)").to_date
    return unless add_permutations(raw_response, answer_values, choice_answer_hash, date)
    add_day(date, answer_values.count)

    answer_values.each do |answer_value|
      answer = choice_answer_hash[answer_value]
      answer.add_day(date)
    end
  end

  private

  def add_permutations(raw_response, answer_values, choice_answer_hash, date)
    permutations = choice_permutation_reporters.where(ca_ids: raw_response.answer).first
    unless permutations
      values = answer_values.map do |av|
        return false if choice_answer_hash[av].nil?
        choice_answer_hash[av].text
      end.join(DisplayFieldValue::VALUE_DELIMITER)
      permutations = choice_permutation_reporters.create(ca_ids: raw_response.answer, values: values)
    end
    permutations.add_day(date)
    true
  end


  def add_day(date, chosen_count)
    day = choice_question_days.find_or_create_by(date: date)
    day.inc(:answered, 1)
    day.inc(:chosen, chosen_count)
    inc(:answered, 1)
    inc(:chosen, chosen_count)
  end

  def choice_question
    @choice_question ||= ChoiceQuestion.find(cq_id)
  end
end
