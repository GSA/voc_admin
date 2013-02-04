# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Takes the SurveyResponses for a given SurveyVersion and bubbles up
# response count totals.  Used for Poll survey types to populate
# the thank you page with summary information.
class PollResults
  attr_accessor :survey_version
  attr_reader :questions

  # Collects the author-chosen choice questions for summary display.
  #
  # @param [SurveyVersion] survey_version the given survey version.
  def initialize(survey_version)
    self.survey_version = survey_version
    @questions = self.survey_version.choice_questions.where(:display_results => true).limit(2)
  end

  # Provides the answer ids and counts for a specified question.  Caches.
  # 
  # @param [ChoiceQuestion] question the given question.
  # @return [Hash] a Hash in the form of: !{"answer_id" => count, "answer_id" => count}
  def answer_counts_for_question(question)
    @answer_counts ||= {}
    @answer_counts[question] ||= calculate_answer_count(question)
  end

  # Totals answer counts for a specified question.
  #
  # @param [ChoiceQuestion] question the given question.
  # @return [Integer] the total number of responses across answers.
  def total_answers_for_question(question)
    answer_counts_for_question(question).values.inject(0, :+)
  end

  private

  # Perform the actual DB querying for calculating answer counts.
  # 
  # @param [ChoiceQuestion] question the given question.
  # @return [Hash] a Hash in the form of: !{"answer_id" => count, "answer_id" => count}
  def calculate_answer_count(question)
    answers = RawResponse.unscoped.includes(:survey_response)
                                  .where(:survey_responses => { :survey_version_id => @survey_version.id },
                                         :question_content_id => question.question_content.id)
                                  .group(:answer).order("count_id desc").count("id")

    ## If the user has chosen multiple answers for a checkbox then those answers come in the form "answer_id, answer_id"
    ## Split these values and add them to the answers hash for those answer_ids
    ## {"1,2" => 1, "1" => 4, "2" => 3} => {"1" => 5, "2" => 4}
    multiple_answers = answers.select {|k,v| k.include?(',') }
    multiple_answers.each do |k,v|
      k.split(',').each {|new_key| answers[new_key] = answers[new_key].to_i + v}
      answers.delete(k)
    end

    ## If there were multiples removed then we need to reorder the answers hash;
    unless multiple_answers.empty?

      # sort by count (value) first, then  -1 * question id (key) to ensure the
      # reversed counts are first in count, then id order
      answers = Hash[answers.sort_by {|a| [a.last, -a.first.to_i] }.reverse]
    end

    return answers
  end
end