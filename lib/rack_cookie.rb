# With the regular Rack session cookie, there's "TypeError: can't dump anonymous module". This will probably not be necessary if Rails is upgraded from 3.0.
class RackCookie < Rack::Session::Cookie
  def call(env)
    send(:load_session, env)
    status, headers, body = @app.call(env)
    env["rack.session"] = env["rack_session"].try(:to_hash)
    send(:commit_session, env, status, headers, body)
  end
end
