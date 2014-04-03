class AddSurveyAlarms < ActiveRecord::Migration
  def self.up
    add_column :surveys, :alarm, :boolean
    add_column :surveys, :alarm_notification_email, :string
  end

  def self.down
  end
end
