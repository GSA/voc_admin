class OrganizationsController < ApplicationController
  before_filter :require_admin

  def index
    @organizations = Organization.search(params[:q])
    if params[:sort]
      @organizations = @organizations.order("#{sort_column} #{sort_direction}")
    end
    @organizations = @organizations.page(params[:page]).per(25)
    if @organizations.count == 0 && params[:q].present?
      flash.now[:notice] = "No organizations were found with search."
    end
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

  def sort_column
    Organization.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
