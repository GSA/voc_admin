class TextQuestionReporter < QuestionReporter

  field :tq_id, type: Integer    # TextQuestion id
  field :question, type: String

  COMMON_WORDS = %w(
      a actually after afterwards albeit all also althoughhowever an and another
      any anybody anything are aren't as at be because before besides both but by can com concerning
      considering conversely each either equally especially eventually everybody
      everyone everything excluding few finally for further furthermore he he's hence
      her hers herself him himself his however http i if i'm in incidentally including
      indeed initially instead into is it it's its itself lastly lest like likewise
      many maybe me mine more moreover most much myself namely neither next nobody none
      nor not notably nothing of off on one oneself onto or otherwise ours ourselves
      particularly previously rather regarding she she's similarly since so someone
      something specifically still than that the their theirs them themselves
      then therefore these they this those though thus to too unless us via we what
      whatever which whichever while who whoever whom whomever whose will with won't you
      your yours yourself yourselves
  )

  # Words used in answers and their counts
  field :words, type: Hash, default: {}

  def exclude_common_words!
    words.except!(*COMMON_WORDS)
  end

  # Generate the data required to create a word cloud for a text question.
  #
  # @return [String] JSON data
  def generate_element_data(display_type, element_type)
    words.map {|k,v| {text: k, weight: v}}.to_json
  end
end
