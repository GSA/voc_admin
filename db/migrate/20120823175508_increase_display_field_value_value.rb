class IncreaseDisplayFieldValueValue < ActiveRecord::Migration
  def self.up
    change_column :display_field_values, :value, :text
    
    # Rerun all Rules as if it was a new comment
    SurveyResponse.all.each {|sr| sr.process_me(1) }
  end

  def self.down
    change_column :display_field_values, :value, :string
  end
end
