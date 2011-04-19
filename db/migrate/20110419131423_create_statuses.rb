class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string :name, :null=>false
      t.timestamps
    end
    
    execute("insert into statuses (id,name) values (1,'new')")
    execute("insert into statuses (id,name) values (2,'processing')")
    execute("insert into statuses (id,name) values (3,'error')")
  end

  def self.down
    drop_table :statuses
  end
end
