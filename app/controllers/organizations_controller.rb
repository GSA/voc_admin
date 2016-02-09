class OrganizationsController < ApplicationController
  before_filter :require_admin

  def index
    @organizations = Organization.search(params[:q]).page(params[:page]).per(25)
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new organization_params

    if @organization.save
      redirect_to organizations_path
    else
      render :new
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name)
  end
end
