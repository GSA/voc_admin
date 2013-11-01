# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Base Controller class; integrates Authlogic and provides gate keeper
# before_filter functions.
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_user
  helper_method :current_user_session, :current_user
  include TokenAndSalt

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

  # If token doesn't exist, check user exists
  def require_token_or_user
    if params[:token].present? && params[:salt].present?
      require_token
    else
      require_user
    end
  end

  # Use for access with a token instead of login
  def require_token
    today = Time.now
    today_string = today.to_date.to_s
    yesterday_string = today.yesterday.to_date.to_s
    return false unless [today_string, yesterday_string].include?(params[:salt])
    params[:token] == token_with_salt(params[:salt])
  end

  # Load Survey and SurveyVersion information from the DB,
  # scoped to the current user for security.
  def get_survey_version
    @survey = @current_user.surveys.find(params[:survey_id])
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end

  # Loads any survey when accessed by token
  def get_survey_version_with_token
    if @current_user
      @survey = @current_user.surveys.find(params[:survey_id])
    elsif params[:token] && params[:salt]
      @survey = Survey.find(params[:survey_id])
    end
    @survey_version = @survey.survey_versions.find(params[:survey_version_id])
  end

  # Additional CSRF protection on unverified (pre-login) requests
  # (Authlogic fix per https://github.com/binarylogic/authlogic/issues/310)
  def handle_unverified_request
    super
    cookies.delete 'user_credentials'
    @current_user_session = @current_user = nil
  end
end
