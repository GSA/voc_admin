class AddFullnameToUsers < ActiveRecord::Migration
  def up
    add_column :users, :fullname, :string

    puts "consolidating user names into fullname"
    User.all.each do |user|
      puts "Updating #{user.f_name} #{user.l_name}"
      user.update_column :fullname, "#{user.f_name} #{user.l_name}"
    end
  end

  def down
    remove_column :users, :fullname
  end
end
