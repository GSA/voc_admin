module ResqueAsyncRunner
  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods
	# We can pass this any class instance method that we want to
	# run later.
	def async(method, *args)
		resque_args = [id, method].concat(args)

		begin
			Resque.enqueue(self.class, *resque_args)
		rescue
			ResquedJob.create(
					class_name: self.class.to_s,
					job_arguments: resque_args
				)
		end
	end
  end

  module ClassMethods
	# This will be called by a worker when a job needs to be processed
	def perform(id, method, *args)
		find(id).send(method, *args)
	end
  end
end
