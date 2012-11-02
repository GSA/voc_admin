class AddRoleIdToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :role_id, :integer
    add_index :users, :role_id

    #
    default_admin = User.find_by_email("sysadmin@ctacorp.com")
    default_admin.update_attribute(:role_id, Role.find_by_name("Admin").id) if default_admin.present?

    admin = User.find_by_email("achaia.walton@hhs.gov")
    admin.update_attribute(:role_id, Role.find_by_name("Admin").id) if admin.present?
  end

  def self.down
    remove_column :users, :role_id
  end
end
