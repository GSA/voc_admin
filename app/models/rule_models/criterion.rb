# == Schema Information
# Schema version: 20110524182200
#
# Table name: criteria
#
#  id             :integer(4)      not null, primary key
#  rule_id        :integer(4)      not null
#  source_id      :integer(4)      not null
#  conditional_id :integer(4)      not null
#  value          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  source_type    :string(255)     not null
#  clone_of_id    :integer(4)
#

class Criterion < ActiveRecord::Base
  belongs_to :rule
  belongs_to :conditional
  belongs_to :source, :polymorphic=>true

  attr_accessor :source_select

  #TODO: need to validate value based on field/question type

  #allows a source to process condition
  def check_me(survey_response)
    if source
      source.check_condition(survey_response, self.conditional_id, self.value)
    else
      false
    end
  end

  def source_select=(source_string)
    self.source_id, self.source_type = source_string.split(',')
  end

end
