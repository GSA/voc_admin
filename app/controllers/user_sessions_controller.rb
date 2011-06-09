class UserSessionsController < ApplicationController
	skip_before_filter :require_no_user, :only => :destroy
  skip_before_filter :require_user, :only => [:new, :create]
  before_filter :redirect_if_logged_in, :only => :new
	
	def new
    @user_session = UserSession.new
  end
	
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to root_path
    else
      render :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to login_url
  end
  
  private
  def redirect_if_logged_in
    redirect_to surveys_path if current_user
  end

end
