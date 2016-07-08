class AddFullnameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :fullname, :string

    puts "consolidating user names into fullname"
    User.all.each do |user|
      puts "Updating #{user.f_name} #{user.l_name}"
      user.update_column :fullname, "#{user.f_name} #{user.l_name}"
    end

    change_column :users, :f_name, :string, null: true
    change_column :users, :l_name, :string, null: true
  end

  def down
    remove_column :users, :fullname
    add_column :users, :f_name, :string, null: false
    add_column :users, :l_name, :string, null: false
  end
end
