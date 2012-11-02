class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :f_name,               :null => false
      t.string :l_name,               :null => false
      t.boolean :locked
      ##### DB columns needed for authlogic authentication #####

      # t.string :login,                :null => false
      t.string :email,                :null => false # use the email as the login
      t.string :crypted_password,     :null => false
      t.string :password_salt,        :null => false
      t.string :persistence_token,    :null => false
#      t.string :single_access_token,  :null => false
#      t.string :perishable_token,     :null => false # Used for email password resets

      # These fields are optional based on which features are wanted from authlogic
      # See Authlogic::Session::MagicColumns for documentation on features
#      t.integer :login_count,         :null => false, :default => 0
#      t.integer :failed_login_count,  :null => false, :default => 0
#      t.datetime :last_request_at
#      t.datetime :current_login_at
#      t.datetime :last_login_at
#      t.string :current_login_ip
#      t.string :last_login_ip
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
