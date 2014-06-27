class ChangeInvitationPercentOnSurveys < ActiveRecord::Migration
  def self.up
    change_column :surveys, :invitation_percent, :decimal, precision: 5, scale: 2, default: 100, null: false
  end
 
  def self.down
    change_column :surveys, :invitation_percent, :integer, default: 100, null: false
  end
end
