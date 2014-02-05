class AddJsError < ActiveRecord::Migration
  def self.up
    add_column :surveys, :js_required_fields_error, :string
  end

  def self.down
    remove_column :surveys, :js_required_fields_error
  end
end
