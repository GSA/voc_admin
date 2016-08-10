class AddPersistenceTokenDefaultToUsers < ActiveRecord::Migration
  def change
    change_column :users, :persistence_token, :string, null: true
  end
end
