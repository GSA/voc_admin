# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of Site entities.
class SitesController < ApplicationController
  before_filter :require_admin

  # GET    /sites(.:format)
  def index
    @sites = Site.search(params[:q])
    if params[:sort]
      @sites = @sites.order("#{sort_column} #{sort_direction}")
    else
      @sites.order("name desc")
    end
    @sites = @sites.page(params[:page]).per(10)

    if @sites.count == 0 && params[:q]
      flash.now[:notice] = "No sites were found with search."
    end
  end

  # GET    /sites/:id(.:format)
  def show
    @site = Site.find params[:id]
  end

  # GET    /sites/new(.:format)
  def new
    @site = Site.new
  end

  # POST   /sites(.:format)
  def create
    @site = Site.new site_params

    if @site.save
      redirect_to @site, :notice => "Successfully created new site."
    else
      render :new
    end
  end

  # GET    /sites/:id/edit(.:format)
  def edit
    @site = Site.find params[:id]
  end

  # PUT    /sites/:id(.:format)
  def update
    @site = Site.find(params[:id])

    if @site.update_attributes(site_params)
      redirect_to @site, :notice => "Successfully updated site."
    else
      render :edit
    end
  end

  # DELETE /sites/:id(.:format)
  def destroy
    @site = Site.find params[:id]

    if @site.surveys.size > 0
      redirect_to sites_path, :notice => "Cannot delete a site with surveys."
    else
      @site.destroy
      redirect_to sites_path, :notice => "Successfully removed site."
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :url, :description)
  end

  def sort_column
    Site.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
