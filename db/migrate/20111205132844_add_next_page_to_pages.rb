class AddNextPageToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :next_page_id, :integer
    add_index :pages, :next_page_id
  end

  def self.down
    remove_column :pages, :next_page_id
  end
end
