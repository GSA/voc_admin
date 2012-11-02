class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_user
  helper_method :current_user_session, :current_user

  private
    def require_admin
      logger.debug "ApplicationController::require_user"
      unless current_user.admin?
        flash[:error] = "You do not have permissions to view this page"
        redirect_to surveys_path
      end
    end

    def current_user_session
      logger.debug "ApplicationController::current_user_session"
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
      # return nil
    end

    def current_user
      logger.debug "ApplicationController::current_user"
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user
      logger.debug "ApplicationController::require_user"
      unless current_user
        flash[:error] = "You must be logged in to access this page."
        redirect_to login_url
        return false
      end
    end

end
