class AddSuppressInvitationToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :suppress_invitation, :boolean, default: false, null: false
  end
end
