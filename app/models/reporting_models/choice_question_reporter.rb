class ChoiceQuestionReporter < QuestionReporter
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  field :q_id, type: Integer    # ChoiceQuestion id
  field :question_text, type: String

  # Total number of Answers chosen across ChoiceQuestion responses;
  # used for simple average count of number of responses (for multiselect)
  field :chosen, type: Integer, default: 0

  embedded_in :survey_version_reporter
  embeds_many :choice_question_days
  embeds_many :choice_answer_reporters
  embeds_many :choice_permutation_reporters

  index "q_id" => 1
  index "choice_question_days.date" => 1

  def type
    @type ||= allows_multiple_selection ? :"choice-multiple" : :"choice-single"
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

  def answered_for_date_range(start_date, end_date, force = false)
    return answered if !force && start_date.nil? && end_date.nil?
    val = days_for_date_range(start_date, end_date).sum(:answered)
    val.nil? ? 0 : val
  end

  def chosen_for_date_range(start_date, end_date, force = false)
    return chosen if !force && start_date.nil? && end_date.nil?
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
    cars = choice_answer_reporters.map {|car| [car.text, car.count_for_date_range(start_date, end_date), car.ca_id]}
    cars.sort_by { |car| -car[1] }
  end

  def choice_answers_str(start_date, end_date, answer_limit = nil)
    answer_reporters = ordered_choice_answer_reporters_for_date_range(start_date, end_date)
    total_answered = answered_for_date_range(start_date, end_date)
    limit_answers = answer_limit && answer_limit < answer_reporters.size
    if limit_answers
      additional_reporters = answer_reporters[answer_limit..-1]
      answer_reporters = answer_reporters[0...answer_limit]
    end
    answer_array = answer_reporters.map do |car|
      "#{car[0]}: #{number_with_delimiter(car[1])} (#{answer_percent(car[1], total_answered)})"
    end
    if limit_answers
      additional_answer_count = additional_reporters.inject(0) {|sum, car| sum + car[1]} # Add count for each reporter
      other_str = "Other Answers: #{number_with_delimiter(additional_answer_count)}"
      other_str << " (#{answer_percent(additional_answer_count, total_answered)})" unless allows_multiple_selection
      answer_array << other_str
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
      total_answered = answered_for_date_range(start_date, end_date)
      ordered_choice_answer_reporters_for_date_range(start_date, end_date).map do |car|
        [car[0], car[1], answer_percent(car[1], total_answered, 1)]
      end
    when "bar"
      ordered_choice_answer_reporters_for_date_range(start_date, end_date).map.each_with_index do |car, index|
        url = survey_responses_path(survey_id: survey_version_reporter.s_id, survey_version_id: survey_version_reporter.sv_id, qc_id: qc_id, search_rr: car[2])
        { data: [[index, car[1]]], label: car[0], count: number_with_delimiter(car[1]), url: url }
      end
    when "line"
      choice_answer_reporters.map do |car|
        data_map = days_with_individual_counts(start_date, end_date).map do |date, count_hash|
          [date.strftime("%Q"), count_hash[car.ca_id]]
        end
        url = survey_responses_path(survey_id: survey_version_reporter.s_id, survey_version_id: survey_version_reporter.sv_id, qc_id: qc_id, search_rr: car.ca_id)
        { data: data_map, label: car.text, url: url }
      end
    else
      nil
    end.to_json
  end

  def allows_multiple_selection
    question.allows_multiple_selection
  end

  def update_reporter!
    choice_answer_hash = {}
    delete_recent_days!
    # initialize all answers with zero counts
    question.choice_answers.each do |ca|
      car = choice_answer_reporters.find_or_create_by(ca_id: ca.id)
      car.text = ca.answer
      choice_answer_hash[ca.id.to_s] = car
    end

    update_time = Time.now
    responses_to_add(question.question_content).find_each do |raw_response|
      add_raw_response(raw_response, choice_answer_hash)
    end
    self.question_text = question.question_content.statement
    self.counts_updated_at = update_time
    save
  end

  def delete_recent_days!
    delete_date = begin_delete_date
    return unless delete_date.present?
    days_for_date_range(delete_date, nil).destroy
    self.answered = answered_for_date_range(nil, nil, true)
    self.chosen = chosen_for_date_range(nil, nil, true)
    choice_answer_reporters.each do |car|
      car.days_for_date_range(delete_date, nil).destroy
      car.count = car.count_for_date_range(nil, nil, true)
    end
    choice_permutation_reporters.each do |cpr|
      cpr.days_for_date_range(delete_date, nil).destroy
      cpr.count = cpr.count_for_date_range(nil, nil, true)
    end
    save
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

  def question
    @question ||= ChoiceQuestion.find(q_id)
  end

  def to_csv(start_date = nil, end_date = nil)
    CSV.generate do |csv|
      csv << ["Question", "Answer", "Count", "Percent"]
      answer_reporters = ordered_choice_answer_reporters_for_date_range(start_date, end_date)
      total_answered = answered_for_date_range(start_date, end_date)
      answer_array = answer_reporters.map do |car|
        [car[0], number_with_delimiter(car[1]), answer_percent(car[1], total_answered)]
      end
      first_line = [question_text]
      first_line += answer_array.shift if answer_array.size > 0
      csv << first_line
      answer_array.each {|answer_arr| csv << [''] + answer_arr}
    end
  end

  def days_with_individual_counts(start_date, end_date)
    @days_with_individual_counts ||= {}
    memo_key = "#{start_date}_#{end_date}"
    return @days_with_individual_counts[memo_key] if @days_with_individual_counts.has_key?(memo_key)
    counts_hash = Hash.new {|hash, key| hash[key] = Hash.new {|h,k| h[k] = 0}}
    days_for_date_range(start_date, end_date).asc(:date).each do |day|
      counts_hash[day.date]
    end
    choice_answer_reporters.each do |car|
      car.choice_answer_days.each do |day|
        counts_hash[day.date][car.ca_id] = day.count
      end
    end
    @days_with_individual_counts[memo_key] = counts_hash
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
    day.inc(answered: 1)
    day.inc(chosen: chosen_count)
    inc(answered: 1)
    inc(chosen: chosen_count)
  end

  def answer_percent(count, total, precision = 2)
    ap = total == 0 ? 0 : count * 100.0 / total
    number_to_percentage(ap, precision: precision)
  end
end
