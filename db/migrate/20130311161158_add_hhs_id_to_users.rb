class AddHhsIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hhs_id, :string, :limit=>50, :unique=>true
  end

  def self.down
    remove_column :users, :hhs_id
  end
end
