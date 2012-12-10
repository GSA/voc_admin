class PagesController < ApplicationController
  before_filter :get_survey_version

  def create
    @page = @survey_version.pages.build params[:page]

    @page.save

    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end

  def update
    @page = @survey_version.pages.find(params[:id])

    @page.update_attributes(params[:page])

    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end

  def move_page
    @page = @survey_version.pages.find(params[:id])
    @target_page = params[:page_number]

    @page.move_page_to(@target_page)

    respond_to do |format|
        format.js  { render "shared/update_question_list" }
    end
  end

  def destroy
    @page = @survey_version.pages.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end

  def copy_page
    page = @survey_version.pages.find(params[:id])
    page.create_copy
    respond_to do |format|
      format.js  { render "shared/update_question_list" }
    end
  end
end
