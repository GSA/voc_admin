class ResquedJob < ActiveRecord::Base
	serialize :job_arguments, Array
end
