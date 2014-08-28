class CreateScanDeletes < ActiveRecord::Migration
  def self.up
    create_table :scan_deletes do |t|
      t.integer :survey_response_id
      t.string :client_id
      t.integer :survey_version_id
      t.datetime :orig_created_at
      t.datetime :orig_updated_at
      t.integer :status_id
      t.datetime :last_processed
      t.string :worker_name
      t.text :page_url
      t.boolean :archived
      t.string :device

      t.timestamps
    end
  end

  def self.down
    drop_table :scan_deletes
  end
end
