class AddLimitAnswersToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :limit_answers, :boolean, :default => false
  end

  def self.down
    remove_column :reports, :limit_answers
  end
end
