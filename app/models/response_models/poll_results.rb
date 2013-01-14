class PollResults
  attr_accessor :survey_version
  attr_reader :questions

  def initialize(survey_version)
    self.survey_version = survey_version
    @questions = self.survey_version.choice_questions.where(:display_results => true).limit(2)
  end

  ## Return the answer counts in a hash for the specified question
  ## {"answer_id" => count, "answer_id" => count}
  def answer_counts_for_question(question)
    @answer_counts ||= {}
    @answer_counts[question] ||= calculate_answer_count(question)
  end

  def total_answers_for_question(question)
    answer_counts_for_question(question).map {|a| a[1]}.inject(0, :+)
  end

  private

  def calculate_answer_count(question)
    answers = RawResponse.unscoped.includes(:survey_response).where(:survey_responses => { :survey_version_id => @survey_version.id}).
      where(:question_content_id => question.question_content.id).group(:answer).order("count_id desc").count("id")

    ## If the user has chosen multiple answers for a checkbox then those answers come in the form "answer_id, answer_id"
    ## Split these values and add them to the answers hash for those answer_ids
    ## {"1,2" => 1, "1" => 4, "2" => 3} => {"1" => 5, "2" => 4}
    multiple_answers = answers.select {|k,v| k.include?(',') }

    multiple_answers.each do |k,v|
      if k.include?(',')
        k.split(',').each {|new_key| answers[new_key] = answers[new_key].to_i + v}
        answers.delete(k)
      else
        answers[k] = answers[k].to_i + v
      end
    end

    ## If there were multiples removed then we need to reorder the answers hash
    unless multiple_answers.empty?
      ## TODO: Is there a better way to do this?
      answers.sort_by {|k,v| v}
    end

    return answers
  end

end