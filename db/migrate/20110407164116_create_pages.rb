class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :number
      t.integer :survey_version_id
      t.integer :style_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
