class AuthlogicMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    AuthlogicRackAdapter.new(env)
    @app.call(env)
  end
end 
