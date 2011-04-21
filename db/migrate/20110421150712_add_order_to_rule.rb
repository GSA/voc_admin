class AddOrderToRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :rule_order, :integer, :null=>false
  end

  def self.down
    remove_column :rules, :rule_order
  end
end
