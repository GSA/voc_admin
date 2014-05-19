class AddDeviceToSurveyResponse < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :device, :string
  end

  def self.down
    remove_column :survey_responses, :device
  end
end
