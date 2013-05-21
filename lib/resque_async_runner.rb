module ResqueAsyncRunner
	# This will be called by a worker when a job needs to be processed
	def self.perform(id, method, *args)
		find(id).send(method, *args)
	end

	# We can pass this any class instance method that we want to
	# run later.
	def async(method, *args)
		Resque.enqueue(self.class, id, method, *args)
	end
end