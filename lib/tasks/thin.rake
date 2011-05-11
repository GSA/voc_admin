namespace :thin do
	desc "Start the thin cluster"
	task :start => [:environment] do 
		sh "thin start -C config/thin_cluster.yml"		
	end
	
	desc "Stop the thin cluster"
	task :stop => [:environment] do
		sh "thin stop -C config/thin_cluster.yml"		
	end
end