class CreateExports < ActiveRecord::Migration
  def self.up
    create_table :exports do |t|

      t.string  :access_token

      t.timestamps
    end
  end

  def self.down
    drop_table :exports
  end
end
