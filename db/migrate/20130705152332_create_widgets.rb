class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.string        :name
      sort_order      :integer(4)
      reportable_id   :integer(4)
      reportable_type :string(255)

      t.timestamps
    end
  end

  def self.down
    drop_table :widgets
  end
end
