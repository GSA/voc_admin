unmatched_display_fields = []
unmatched_rules = []

SurveyVersion.all.each do |sv|
  sv.display_fields.each do |df|
    if !sv.choice_questions.any? {|cq| cq.question_content.statement == df.name } &&
       !sv.text_questions.any? {|tq| tq.question_content.statement == df.name } &&
       !sv.matrix_questions.any? { |mq| mq.choice_questions.any? { |cq| "#{mq.question_content.statement}: #{cq.question_content.statement}" == df.name} }
      unmatched_display_fields << df
    end
  end

  sv.rules.each do |rule|
    if !sv.choice_questions.any? {|cq| cq.question_content.statement == rule.name} &&
       !sv.text_questions.any? {|tq| tq.question_content.statement == rule.name } &&
       !sv.matrix_questions.any? {|mq| mq.choice_questions.any? {|cq| "#{mq.question_content.statement}: #{cq.question_content.statement}" == rule.name} }
      unmatched_rules << rule
    end
  end
end

puts unmatched_display_fields.count
puts unmatched_rules.count

unmatched_display_fields.each {|df| df.update_attribute(:editable, true) }

