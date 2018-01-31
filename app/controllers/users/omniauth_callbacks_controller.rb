class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :require_user
  skip_before_filter :verify_authenticity_token

  def saml
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])
    #l = Logger.new(STDOUT)
    #l.info("LoginSAML id:#{@user.id} email:#{@user.email}")
    sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    set_flash_message(:notice, :success, :kind => "Saml") if is_navigational_format?
  end

  def developer
    @user = User.from_omniauth(request.env['omniauth.auth'])
    #l = Logger.new(STDOUT)
    #l.info("LoginDEV id:#{@user.id} email:#{@user.email}")
    sign_in_and_redirect @user, event: :authentication
  end

  def failure
    redirect_to root_path
  end
end
