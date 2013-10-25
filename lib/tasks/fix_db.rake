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
end

