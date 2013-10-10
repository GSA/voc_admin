class ChoicePermutationReporter
  include Mongoid::Document

  field :ca_ids, type: String
  field :values, type: String
  field :count, type: Integer, default: 0

  embedded_in :choice_question_reporter
  embeds_many :choice_permutation_days

  Permutation = Struct.new(:values, :count)

  def permutation
    Permutation.new(values.split(DisplayFieldValue::VALUE_DELIMITER), count)
  end
end
