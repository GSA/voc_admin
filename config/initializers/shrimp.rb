CommentToolApp::Application.config.middleware.use Shrimp::Middleware, {rendering_time: 5000}, :only => %r[/dashboards/]
