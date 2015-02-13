class AddLocaleToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :locale, :string
  end

  def self.down
    remove_column :surveys, :locale
  end
end
