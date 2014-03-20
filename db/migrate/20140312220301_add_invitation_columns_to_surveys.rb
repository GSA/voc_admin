class AddInvitationColumnsToSurveys < ActiveRecord::Migration
  def self.up
    add_column :surveys, :invitation_text, :text
    add_column :surveys, :invitation_accept_button_text, :string
    add_column :surveys, :invitation_reject_button_text, :string
  end

  def self.down
    remove_column :surveys, :invitation_text
    remove_column :surveys, :invitation_accept_button_text
    remove_column :surveys, :invitation_reject_button_text
  end
end
