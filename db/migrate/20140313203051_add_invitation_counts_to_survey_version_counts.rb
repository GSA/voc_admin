class AddInvitationCountsToSurveyVersionCounts < ActiveRecord::Migration
  def self.up
    add_column :survey_version_counts, :invitations, :integer, :default => 0
    add_column :survey_version_counts, :invitations_accepted, :integer, :default => 0
  end

  def self.down
    remove_column :survey_version_counts, :invitations
    remove_column :survey_version_counts, :invitations_accepted
  end
end
