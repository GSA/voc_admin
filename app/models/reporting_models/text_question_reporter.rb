class TextQuestionReporter < QuestionReporter
  include ActionView::Helpers::NumberHelper

  field :tq_id, type: Integer    # TextQuestion id
  field :question, type: String

  embeds_many :text_question_days

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

  def self.generate_reporter(survey_version, text_question)
    text_question_reporter = TextQuestionReporter.find_or_create_by(tq_id: text_question.id)
    self.set_common_fields(text_question_reporter, survey_version, text_question)
    question_content = text_question.question_content
    text_question_reporter.question = question_content.statement

    question_content.raw_responses.each do |raw_response|
      answer_values = raw_response.answer.try(:downcase).try(:scan, /[\w'-]+/)
      text_question_reporter.add_answer_values(answer_values, raw_response.created_at)
    end
    text_question_reporter.save
  end

  def add_answer_values(answer_values, date)
    return unless answer_values.present?
    inc(:answered, 1)
    tqd = text_question_days.find_or_create_by(date: date)
    tqd.inc(:answered, 1)

    answer_values = answer_values.uniq - COMMON_WORDS
    answer_values.each do |answer_value|
      word = answer_value
      count = words[word] || 0
      words[word] = count + 1
      count = tqd.words[word] || 0
      tqd.words[word] = count + 1
    end
  end

  def words_for_date_range(start_date, end_date)
    return words if start_date.nil? && end_date.nil?
    days = text_question_days_for_date_range(start_date, end_date)
    days.inject({}) {|hash, day| hash.merge(day.words) {|k, oldval, newval| oldval + newval}}
  end

  def top_words_for_date_range(start_date, end_date, word_limit = 50)
    word_hash = words_for_date_range(start_date, end_date)
    top_words(word_limit, word_hash)
  end

  def answered_for_date_range(start_date, end_date)
    return answered if start_date.nil? && end_date.nil?
    days = text_question_days_for_date_range(start_date, end_date)
    days.sum(:answered)
  end

  def top_words(word_limit = 50, word_hash = nil)
    word_hash ||= words
    new_words = word_hash.sort_by {|k,v| v}
    if new_words.size > word_limit
      new_words = new_words[-word_limit..-1]
    end
    Hash[new_words]
  end

  # Generate the data required to create a word cloud for a text question.
  #
  # @return [String] JSON data
  def generate_element_data(display_type, start_date = nil, end_date = nil)
    top_words_for_date_range(start_date, end_date).map do |k,v|
      {
        text: k,
        weight: v,
        html: {title: "#{k}: #{number_with_delimiter(v)}"}
      }
    end.to_json
  end

  protected

  def text_question_days_for_date_range(start_date, end_date)
    days = text_question_days
    days = days.where(:date.gte => start_date.to_date) unless start_date.nil?
    days = days.where(:date.lte => end_date.to_date) unless end_date.nil?
    days
  end
end
