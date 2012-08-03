class CreateEmailActions < ActiveRecord::Migration
  def self.up
    create_table :email_actions do |t|
      t.string :emails
      t.string :subject
      t.text :body
      t.integer :rule_id
      t.integer :clone_of_id

      t.timestamps
    end
  end

  def self.down
    drop_table :email_actions
  end
end
