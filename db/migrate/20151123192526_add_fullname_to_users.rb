class AddFullnameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :fullname, :string

    puts "consolidating user names into fullname"
    User.all.each do |user|
      puts "Updating #{user.name}"
      user.update_column :fullname, user.name
    end
  end

  def down
    remove_column :users, :fullname
  end
end
