module ReportsHelper
  def top_words(text_question_reporter)
    words = text_question_reporter.top_words_for_date_range(@report.start_date, @report.end_date)
    total_answered = text_question_reporter.answered_for_date_range(@report.start_date, @report.end_date)
    words_array = words.map do |k, v| 
      word_percent = total_answered == 0 ? 0 : v * 100.0 / total_answered
      word_percent = number_to_percentage(word_percent, precision: 2)
      "#{sanitize(k)}: #{number_with_delimiter(v)} (#{word_percent})"
    end
    words_array.reverse.join(", ")
  end

  def choice_question_reporter_answers(choice_question_reporter)
    answer_reporters = choice_question_reporter.ordered_choice_answer_reporters_for_date_range(@report.start_date, @report.end_date)
    total_answered = choice_question_reporter.answered_for_date_range(@report.start_date, @report.end_date)
    answer_array = answer_reporters.map do |car| 
      answer_percent = total_answered == 0 ? 0 : car[1] * 100.0 / total_answered
      answer_percent = number_to_percentage(answer_percent, precision: 2)
      "#{car[0]}: #{number_with_delimiter(car[1])} (#{answer_percent})"
    end
    answer_array.join(", ")
  end
end
