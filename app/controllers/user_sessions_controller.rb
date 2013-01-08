# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the UserSession lifecycle. Also provides password
# reset functionality.
class UserSessionsController < ApplicationController
  skip_before_filter :require_user, :only => [:new, :create, :reset_password, :do_pw_reset]
  before_filter :redirect_if_logged_in, :only => :new

	# GET    /user_sessions/new(.:format)
  def new
    @user_session = UserSession.new
  end

  # POST   /user_sessions(.:format)
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to root_path
    else
      render :new
    end
  end

  # DELETE /user_sessions/:id(.:format)
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to login_url
  end

  # POST   /user_sessions/do_pw_reset(.:format)
  def do_pw_reset
    user = User.find_by_email(params["email_address"])
    if user
      password = PasswordGenerator::generate_password(2,2,2,2)
      user.password = password
      user.password_confirmation = password

      if user.save_without_session_maintenance
        UserSessionsMailer.reset_password(user, password).deliver
      end
    end
    flash.notice = "An email has been sent to #{params["email_address"]}, if the account existed."
    redirect_to login_path
  end

  private

  # If the user is already logged in and a new UserSession is requested,
  # redirect the /surveys instead.
  def redirect_if_logged_in
    redirect_to surveys_path if current_user
  end
end
