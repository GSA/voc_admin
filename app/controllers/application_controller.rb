# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Base Controller class; integrates Authlogic and provides gate keeper
# before_filter functions.
class ApplicationController < ActionController::Base
  def new_session_path(scope)
    new_user_session_path
  end

  config.relative_url_root = ""
  protect_from_forgery
  before_filter :require_user
  include TokenAndSalt

  private

  # Used to restrict access to User and Site functionality.
  def require_admin
    logger.debug "ApplicationController::require_user"
    if current_user.admin?
      return true
    else
      flash[:error] = "You do not have permissions to view this page"
      redirect_to surveys_path
    end
  end

  # Used to restrict application functionality to logged-in Users.
  def require_user
    logger.debug "ApplicationController::require_user"
    if current_user
      return true
    else
      flash[:error] = "You must be logged in to access this page."
      if Rails.env.development? || ENV['DEBUG_ACCESS'].present?
        redirect_to "/users/auth/developer"
      else
        redirect_to user_omniauth_authorize_path(:saml)
      end
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
end
