class ChoicePermutationDay
  include Mongoid::Document

  field :count, type: Integer, default: 0

  embedded_in :choice_permutation_reporter
end
