class ChoicePermutationReporter
  include Mongoid::Document

  field :ca_ids, type: String
  field :values, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
  embeds_many :choice_permutation_days
  index "choice_permutation_days.date" => 1

  Permutation = Struct.new(:values, :count)

  def permutation
    Permutation.new(values.split(DisplayFieldValue::VALUE_DELIMITER), count)
  end

  def add_day(date)
    day = choice_permutation_days.find_or_create_by(date: date)
    day.inc(:count, 1)    
    inc(:count, 1)
  end
end
