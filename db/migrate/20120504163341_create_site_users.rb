class CreateSiteUsers < ActiveRecord::Migration
  def self.up
    create_table :site_users do |t|
      t.integer :site_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :site_users
  end
end
