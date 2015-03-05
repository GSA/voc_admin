class ResquedJob < ActiveRecord::Base
	serialize :job_arguments, Array
end

# == Schema Information
#
# Table name: resqued_jobs
#
#  id            :integer          not null, primary key
#  class_name    :string(255)
#  job_arguments :text(2147483647)
#  created_at    :datetime
#  updated_at    :datetime
#

