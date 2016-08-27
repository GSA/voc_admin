class TextQuestionReporter < QuestionReporter
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  field :q_id, type: Integer    # TextQuestion id
  field :question_text, type: String

  embedded_in :survey_version_reporter
  embeds_many :text_question_days
  embeds_many :count_days

  index "q_id" => 1

  COMMON_WORDS = %w(
      a actually after afterwards albeit all also althoughhowever am an and another
      any anybody anything are aren't as at be because before besides both but by can com concerning
      considering conversely did didn't does doesn't each either equally especially eventually everybody
      everyone everything excluding few finally for further furthermore has hasn't have haven't he he's hence
      her hers herself him himself his however http i if i'm in incidentally including
      indeed initially instead into is it it's its itself lastly lest like likewise
      many maybe me mine more moreover most much my myself namely neither next no nobody none
      nor not notably nothing of off on one oneself onto or otherwise ours ourselves
      particularly previously rather regarding she she's similarly since so someone
      something specifically still than that the their theirs them themselves
      then therefore these they this those though thus to too unless us via was we what
      whatever which whichever while who whoever whom whomever whose will with won't you
      your yours yourself yourselves
  )

  # Words used in answers and their counts
  field :words, type: Hash, default: {}

  def type
    :text
  end

  def update_reporter!
    delete_recent_days!

    update_time = Time.now
    responses_to_add(question.question_content).find_each do |raw_response|
      answer_values = raw_response.answer.try(:downcase).try(:scan, /[\w'-]+/)
      add_answer_values(answer_values, raw_response.created_at)
    end
    self.question_text = question.question_content.statement
    self.counts_updated_at = update_time
    save
  end

  def delete_recent_days!
    delete_date = begin_delete_date
    return unless delete_date.present?
    days_for_date_range(delete_date, nil).destroy
    self.words = words_for_date_range(nil, nil, true)
    self.answered = answered_for_date_range(nil, nil, true)
    save
  end

  def add_answer_values(answer_values, date)
    return unless answer_values.present?
    date = date.in_time_zone("Eastern Time (US & Canada)").to_date
    inc(answered: 1)
    tqd = text_question_days.find_or_create_by(date: date)
    tqd.inc(answered: 1)

    answer_values = answer_values.uniq - COMMON_WORDS
    answer_values.each do |answer_value|
      word = answer_value
      count = words[word] || 0
      words[word] = count + 1
      count = tqd.words[word] || 0
      tqd.words[word] = count + 1
    end
  end

  def words_for_date_range(start_date, end_date, force = false)
    return words if !force && start_date.nil? && end_date.nil?
    days = days_for_date_range(start_date, end_date)
    days.inject({}) {|hash, day| hash.merge(day.words) {|k, oldval, newval| oldval + newval}}
  end

  def top_words_for_date_range(start_date, end_date, word_limit = 50)
    word_hash = words_for_date_range(start_date, end_date)
    top_words(word_limit, word_hash)
  end

  def answered_for_date_range(start_date, end_date, force = false)
    return answered if !force && start_date.nil? && end_date.nil?
    val = days_for_date_range(start_date, end_date).sum(:answered)
    val.nil? ? 0 : val
  end

  def top_words(word_limit = 50, word_hash = nil)
    word_hash ||= words
    new_words = word_hash.sort_by {|k,v| v}
    if new_words.size > word_limit
      new_words = new_words[-word_limit..-1]
    end
    Hash[new_words]
  end

  def top_words_str(start_date, end_date, answer_limit = nil)
    words = top_words_for_date_range(start_date, end_date)
    total_answered = answered_for_date_range(start_date, end_date)
    words_array = words.to_a.reverse
    limit_answers = answer_limit && answer_limit < words_array.size
    if limit_answers
      additional_words = words_array[answer_limit..-1]
      words_array = words_array[0...answer_limit]
    end
    words_array = words_array.map do |word, count|
      "#{sanitize(word)}: #{number_with_delimiter(count)} (#{word_percent(count, total_answered)})"
    end
    # Don't add Other Words for now
    # if limit_answers
    #   additional_word_count = additional_words.inject(0) {|sum, a| sum + a[1]} # Add count for each word (Hash converted to Array)
    #   words_array << "Other Words: #{number_with_delimiter(additional_word_count)} (#{word_percent(additional_word_count, total_answered)})"
    # end
    words_array.join(", ")
  end

  # Generate the data required to create a word cloud for a text question.
  #
  # @return [String] JSON data
  def generate_element_data(display_type, start_date = nil, end_date = nil)
    top_words_for_date_range(start_date, end_date).map do |k,v|
      text = sanitize(k)
      {
        text: text,
        weight: v,
        html: {title: "#{text}: #{number_with_delimiter(v)}"},
        link: survey_responses_path(survey_id: survey_version_reporter.s_id, survey_version_id: survey_version_reporter.sv_id, qc_id: qc_id, search_rr: text)
      }
    end.to_json
  end

  def question
    @question ||= TextQuestion.find(q_id)
  end

  def to_csv(start_date = nil, end_date = nil)
    CSV.generate do |csv|
      csv << ["Question", "Word", "Count", "Percent"]
      words = top_words_for_date_range(start_date, end_date)
      total_answered = answered_for_date_range(start_date, end_date)
      words_array = words.map do |k, v|
        [k, number_with_delimiter(v), word_percent(v, total_answered)]
      end
      words_array.reverse!
      first_line = [question_text]
      first_line += words_array.shift if words_array.size > 0
      csv << first_line
      words_array.each {|word_arr| csv << [''] + word_arr}
    end
  end

  protected

  def days_for_date_range(start_date, end_date)
    days = text_question_days
    days = days.where(:date.gte => start_date.to_date) unless start_date.nil?
    days = days.where(:date.lte => end_date.to_date) unless end_date.nil?
    days
  end

  def word_percent(count, total)
    wp = total == 0 ? 0 : count * 100.0 / total
    number_to_percentage(wp, precision: 2)
  end
end
