class CountDay
  include Mongoid::Document

  field :date, type: Date
  field :questions_asked, type: Integer
  field :questions_skipped, type: Integer
end
