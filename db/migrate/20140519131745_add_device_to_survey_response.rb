class AddDeviceToSurveyResponse < ActiveRecord::Migration
  def self.up
    add_column :survey_responses, :device, :string, default: 'Desktop'
  end

  def self.down
    remove_column :survey_responses, :device
  end
end
