# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Helper class for evaluating comparison truth.
class ConditionTester
  
  # Compares an answer against a test_value using a specific Conditional.
  #
  # @param [Integer] conditional_id the operation to test against
  # @param [String] answer the first value to test
  # @param [String] test_value the second value to test
  def self.test(conditional_id, answer, test_value)
    case conditional_id
      when 1 #"="
        answer == test_value
      when 2 #"!="
        answer != test_value
      when 3 #"contains"
        answer.match /#{test_value}/i || false
      when 4 #"does not contain"
        !(answer.match /#{test_value}/i || false)
      when 5 #"<"
        answer.to_i < test_value.to_i
      when 6 #"<="
        answer.to_i <= test_value.to_i
      when 7 #">="
        answer.to_i >= test_value.to_i
      when 8 #">"
        answer.to_i > test_value.to_i
      when 9 #"empty"
        answer.blank?
      when 10 #"not empty"
        !answer.blank?
      else
        false
    end
  end
end