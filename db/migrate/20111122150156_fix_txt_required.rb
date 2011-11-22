class FixTxtRequired < ActiveRecord::Migration
  def self.up
    change_column("question_contents", "required", :boolean, :default=>false)
  end

  def self.down
    change_column("question_contents", "required", :boolean, :default=>true)
  end
end
