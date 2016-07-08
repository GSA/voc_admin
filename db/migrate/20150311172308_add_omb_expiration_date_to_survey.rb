class AddOmbExpirationDateToSurvey < ActiveRecord::Migration
  def self.up
    add_column :surveys, :omb_expiration_date, :string
  end

  def self.down
    remove_column :surveys, :omb_expiration_date
  end
end
