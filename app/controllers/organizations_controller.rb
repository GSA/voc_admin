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

  def edit
    @organization = Organization.find params[:id]
  end

  def update
    @organization = Organization.find params[:id]

    if @organization.update(organization_params)
      redirect_to organizations_path
    else
      render :edit
    end
  end

  def destroy
    @organization = Organization.find params[:id]
    @organization.destroy
    redirect_to organizations_path, notice: "Successfully deleted organization"
  end

  private

  def organization_params
    params.require(:organization).permit(:name)
  end
end
