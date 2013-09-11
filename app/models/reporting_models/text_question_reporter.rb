class TextQuestionReporter < QuestionReporter

  field :tq_id, type: Integer    # TextQuestion id
  field :question, type: String

  COMMON_WORDS = %W(
      a actually after afterwards albeit all also althoughhowever an and another
      any anybody anything as at because before besides both but by concerning
      considering conversely each either equally especially eventually everybody
      everyone everything excluding few finally for further furthermore he hence
      her hers herself him himself his however i if in incidentally including
      indeed initially instead into is it its itself lastly lest like likewise
      many me mine more moreover most much myself namely neither next nobody none
      nor notably nothing of off on one oneself onto or otherwise ours ourselves
      particularly previously rather regarding she similarly since so someone
      something specifically still than that the their theirs them themselves
      then therefore these they those though thus too unless us via we what
      whatever which whichever while who whoever whom whomever whose with you
      your yours yourself yourselves
  )

  # Words used in answers and their counts
  field :words, type: Hash, default: {}

  def exclude_common_words!
    words.except!(*COMMON_WORDS)
  end
end
