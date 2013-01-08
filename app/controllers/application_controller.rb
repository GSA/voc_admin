# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Base Controller class; integrates Authlogic and provides gate keeper
# before_filter functions.
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_user
  helper_method :current_user_session, :current_user

  private
  
  # Used to restrict access to User and Site functionality.
  def require_admin
    logger.debug "ApplicationController::require_user"
    unless current_user.admin?
      flash[:error] = "You do not have permissions to view this page"
      redirect_to surveys_path
    end
  end

  # Retrieves the UserSession.
  def current_user_session
    logger.debug "ApplicationController::current_user_session"
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
    # return nil
  end

  # Retrieves the User from the UserSession.
  def current_user
    logger.debug "ApplicationController::current_user"
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  # Used to restrict application functionality to logged-in Users.
  def require_user
    logger.debug "ApplicationController::require_user"
    unless current_user
      flash[:error] = "You must be logged in to access this page."
      redirect_to login_url
      return false
    end
  end

  # Load Survey and SurveyVersion information from the DB,
  # scoped to the current user for security.
  def get_survey_version
    @survey = @current_user.surveys.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end
end
