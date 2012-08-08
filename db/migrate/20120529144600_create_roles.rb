class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end

    # Create the default role for admins
    role = Role.find_or_create_by_name("Admin")
  end

  def self.down
    drop_table :roles
  end
end
