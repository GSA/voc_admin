class AddRawSubmitTable < ActiveRecord::Migration
  def self.up
    create_table :raw_submissions do |t|
      t.string :uuid_key
      t.integer :survey_id
      t.integer :survey_version_id
      t.text :post, :limit => 65535
      t.boolean :submitted, default: 0
      t.timestamps
    end
  end

  def self.down
  end
end
