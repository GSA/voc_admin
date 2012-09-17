unmatched_display_fields = []

SurveyVersion.all.each do |sv|
  sv.display_fields.each do |df|
    if !sv.choice_questions.any? {|cq| cq.question_content.statement == df.name } &&
       !sv.text_questions.any? {|tq| tq.question_content.statement == df.name } &&
       !sv.matrix_questions.any? { |mq| mq.choice_questions.any? { |cq| "#{mq.question_content.statement}: #{cq.question_content.statement}" == df.name} }
      unmatched_display_fields << df
    end
 end
end

puts unmatched_display_fields.count

unmatched_display_fields.each {|df| df.update_attribute(:editable, true) }
