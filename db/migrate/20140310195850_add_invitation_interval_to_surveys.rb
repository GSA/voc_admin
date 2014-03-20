class AddInvitationIntervalToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :invitation_interval, :integer, default: 30, null: false
  end

  def self.down
    remove_column :surveys, :invitation_interval
  end
end
