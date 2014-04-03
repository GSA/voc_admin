namespace :fix_db do
  desc "Repair Rule action targets"
  task :fix_actions => [:environment] do
    sv = SurveyVersion.find(53)

    replaced_values = []

    sv.rules.each do |r|
      r.actions.where(value_type: "Response").each do |a|

        match = sv.options_for_action_select.select { |o| o[0] == "#{a.display_field.name} response" }.first

        unless match.nil? or match[1] == a.value
          replaced_values << { action_id: a.id, old_val: a.value, new_val: match[1] }

          a.value = match[1]
          a.save!
        end
      end
    end

    puts "IF NECESSARY TO REVERT! Start the console: RAILS_ENV=production rails c"
    puts " "
    puts "Then run this command:"
    puts " "
    puts "[#{replaced_values.map { |rv| rv.to_s }.join(",")}].each {|a| Action.find(a[:action_id]).update_attribute(:value, a[:old_val])} and 'Reverted.'"
    puts " "
    puts "You can exit when it reports 'Reverted.'"
  end

  desc "create join table entries for existing questions and display_field relationships"
  task :populate_display_field_question_table => [:environment] do
    QuestionContent.find_in_batches do |question_contents|
      question_contents.each do |question_content|
        next if question_content.matrix_question?
        name = if question_content.questionable_type == "ChoiceQuestion" &&
          question_content.questionable.matrix_question.present?
            "#{question_content.questionable.matrix_question.question_content.statement}: #{question_content.statement}"
          else
            question_content.statement
          end
        next if question_content.survey_version.nil?
        display_field = question_content.survey_version.display_fields
          .find_by_name(name)

        if display_field.nil?
          puts "Did not find a display field for QC: #{question_content.id}"
          next
        else
          puts "Adding DisplayField: #{display_field.id} to QuestionContent: #{question_content.id}"
          question_content.display_fields << display_field
        end
      end
    end
  end
end
