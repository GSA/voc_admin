class AddLdapUsername < ActiveRecord::Migration
  def self.up
    add_column :users, :username, :string, :limit=>50, :unique=>true
    change_column :users, :crypted_password, :string, :null=> true
  end

  def self.down
    remove_column :users, :username
  end
end
