class IncreaseDisplayFieldValueValue < ActiveRecord::Migration
  def self.up
    change_column :display_field_values, :value, :text
    
    # Rerun all Rules as if it was a new comment
    SurveyResponse.all.each do |sr|
       begin
         sr.process_me(1)
       rescue
         #
       end
    end 
  end

  def self.down
    change_column :display_field_values, :value, :string
  end
end
