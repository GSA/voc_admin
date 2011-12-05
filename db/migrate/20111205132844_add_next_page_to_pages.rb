class AddNextPageToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :next_page_id, :integer
  end

  def self.down
    remove_column :pages, :next_page_id
  end
end
