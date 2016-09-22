
if ENV['RAILS_ENV'] == 'production'
  require 'unicorn/worker_killer'

  max_request_min =  500
  max_request_max =  600

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, max_request_min, max_request_max

  oom_min = 350 * (1024**2)
  oom_max = 364 * (1024**2)

  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

# include map and a path if not installing this application at the root path
#map '/vocsub' do
	require ::File.expand_path('../config/environment',  __FILE__)
	run CommentToolApp::Application
#end
