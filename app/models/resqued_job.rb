class ResquedJob < ActiveRecord::Base
	serialize :job_arguments, Hash
end
