class AddInvitationPercentToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :invitation_percent, :integer, default: 100, null: false
  end

  def self.down
    remove_column :surveys, :invitation_percent
  end
end
