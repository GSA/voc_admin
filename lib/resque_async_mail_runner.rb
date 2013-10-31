module ResqueAsyncMailRunner
  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
	# We can pass this any class method that we want to run later.
	def async(method, *args)
		resque_args = [method].concat(args)

		begin
			Resque.enqueue(self.name.constantize, *resque_args)
		rescue
			ResquedJob.create(
					class_name: self.name,
					job_arguments: resque_args
				)
		end
	end

	# This will be called by a worker when a job needs to be processed
	def perform(method, *args)
		send(method, *args).send(:deliver)
	end
  end
end
