# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the UserSession lifecycle. Also provides password
# reset functionality.
class UserSessionsController < ApplicationController

  skip_before_filter :require_user, :only => [:new, :create, :reset_password, :do_pw_reset]
  before_filter :redirect_if_logged_in, :only => :new

  before_filter :openam_login, only: :new
  before_filter :openam_logout, only: :destroy

  # NEW comes from the OpenAM gem now!
  # GET    /user_sessions/new(.:format)
  def new
  end

  # DESTROY comes from the OpenAM gem now!
  # DELETE /user_sessions/:id(.:format)
  def destroy
  end

  private

  # If the user is already logged in and a new UserSession is requested,
  # redirect the /surveys instead.
  def redirect_if_logged_in
    redirect_to surveys_path if current_user
  end
end
