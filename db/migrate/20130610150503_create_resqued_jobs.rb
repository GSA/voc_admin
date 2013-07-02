class CreateResquedJobs < ActiveRecord::Migration
  def self.up
    create_table :resqued_jobs do |t|
      t.string :class_name
      t.text :job_arguments, :limit => 16777215

      t.timestamps
    end
  end

  def self.down
    drop_table :resqued_jobs
  end
end
