class CreateRecurringReports < ActiveRecord::Migration
  def self.up
    create_table :recurring_reports do |t|
      t.references :report
      t.integer :user_created_by_id
      t.string :user_created_by_string
      t.integer :user_last_modified_by_id
      t.string :frequency
      t.integer :day_of_week
      t.integer :day_of_month
      t.integer :month
      t.string :emails, :limit => 1000
      t.boolean :pdf
      t.datetime :last_sent_at
      t.timestamps
    end
  end

  def self.down
    drop_table :recurring_reports
  end
end
