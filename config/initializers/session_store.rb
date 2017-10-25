CommentToolApp::Application.config.session_store :cookie_store, :key => '_comment_tool_app_session', :secure => true, :httponly => true
# Be sure to restart your server when you modify this file.

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# CommentToolApp::Application.config.session_store :active_record_store, {:domain => "dev.vocapp.com"}
