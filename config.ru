# include map and a path if not installing this application at the root path
#map '/vocsub' do
	require ::File.expand_path('../config/environment',  __FILE__)
  # require 'shrimp'
  use RackCookie, :key => 'rack.session',
                  :path => '/',
                  :expire_after => 2592000,
                  :secret => CommentToolApp::Application.config.secret_token
  require 'pdfkit'
  use PDFKit::Middleware, {:'redirect-delay' => 400}, :only => %r[/pdf/]
	run CommentToolApp::Application
#end

# require ::File.expand_path('../config/environment',  __FILE__)
# run CommentToolApp::Application
