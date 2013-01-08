# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of Page entities.
class PagesController < ApplicationController
  before_filter :get_survey_version

  # /surveys/:survey_id/survey_versions/:survey_version_id/pages(.:format)
  def create
    @page = @survey_version.pages.build params[:page]

    @page.save

    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end

  # /surveys/:survey_id/survey_versions/:survey_version_id/pages/:id(.:format)
  def update
    @page = @survey_version.pages.find(params[:id])

    @page.update_attributes(params[:page])

    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end

  # /surveys/:survey_id/survey_versions/:survey_version_id/pages/:id/move_page(.:format)
  def move_page
    @page = @survey_version.pages.find(params[:id])
    @target_page = params[:page_number]

    @page.move_page_to(@target_page)

    respond_to do |format|
        format.js  { render "shared/update_question_list" }
    end
  end

  # /surveys/:survey_id/survey_versions/:survey_version_id/pages/:id(.:format)
  def destroy
    @page = @survey_version.pages.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end

  # /surveys/:survey_id/survey_versions/:survey_version_id/pages/:id/copy_page(.:format)
  def copy_page
    page = @survey_version.pages.find(params[:id])
    page.create_copy
    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end
end
