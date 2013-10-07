class TextQuestionReporter < QuestionReporter
  include ActionView::Helpers::NumberHelper

  field :tq_id, type: Integer    # TextQuestion id
  field :question, type: String

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
  field :top_words, type: Hash, default: {}

  def type
    :text
  end

  def exclude_common_words!
    words.except!(*COMMON_WORDS)
  end

  def populate_top_words!(word_limit = 50)
    new_words = words.sort_by {|k,v| v}
    if new_words.size > word_limit
      new_words = new_words[-word_limit..-1]
    end
    self.top_words = Hash[new_words]
  end

  # Generate the data required to create a word cloud for a text question.
  #
  # @return [String] JSON data
  def generate_element_data(display_type)
    top_words.map do |k,v|
      {
        text: k,
        weight: v,
        html: {title: "#{k}: #{number_with_delimiter(v)}"}
      }
    end.to_json
  end
end
