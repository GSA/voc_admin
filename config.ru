# include map and a path if not installing this application at the root path
#map '/vocsub' do
	require ::File.expand_path('../config/environment',  __FILE__)
	run CommentToolApp::Application
#end

# require ::File.expand_path('../config/environment',  __FILE__)
# run CommentToolApp::Application
