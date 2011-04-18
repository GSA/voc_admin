# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CommentToolApp::Application.initialize!

# Load Common Models
Dir["#{Rails.root.to_s}/../comment_tool_common/models/*.rb"].each {|file| require file }