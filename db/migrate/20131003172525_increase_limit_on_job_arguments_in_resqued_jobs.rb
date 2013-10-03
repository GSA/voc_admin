class IncreaseLimitOnJobArgumentsInResquedJobs < ActiveRecord::Migration
  def self.up
    change_column :resqued_jobs, :job_arguments, :text, :limit => 2147483647
  end

  def self.down
    change_column :resqued_jobs, :job_arguments, :text, :limit => 16777215
  end
end
