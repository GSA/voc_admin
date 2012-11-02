class SitesController < ApplicationController
  before_filter :require_admin

  def index
    @sites = Site.order("name asc").page(params[:page]).per(10)
  end

  def show
    @site = Site.find params[:id]
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new params[:site]

    if @site.save
      redirect_to @site, :notice => "Successfully created new site."
    else
      render :new
    end
  end

  def edit
    @site = Site.find params[:id]
  end

  def update
    @site = Site.find(params[:id])

    if @site.update_attributes(params[:site])
      redirect_to @site, :notice => "Successfully updated site."
    else
      render :edit
    end
  end

  def destroy
    @site = Site.find params[:id]

    @site.destroy

    redirect_to sites_path, :notice => "Successfully removed site."
  end
end
