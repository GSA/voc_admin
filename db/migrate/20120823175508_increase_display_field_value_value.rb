class IncreaseDisplayFieldValueValue < ActiveRecord::Migration
  def self.up
    change_column :display_field_values, :value, :text

    # Rerun all Rules as if it was a new comment
    SurveyResponse.find_in_batches(:batch_size => 1000) do |survey_responses|
      survey_responses.each do |sr|
        begin
          sr.process_me(1)
        rescue
          #
        end # rescue
      end # .each
    end # find_in_batches
  end

  def self.down
    change_column :display_field_values, :value, :string
  end
end
