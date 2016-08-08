class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def saml
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    set_flash_message(:notice, :success, :kind => "Saml") if is_navigational_format?
  end

  def failure
    redirect_to root_path
  end
end
