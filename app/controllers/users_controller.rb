class UsersController < ApplicationController
  before_filter :require_admin, :except => [:edit, :update]
  
  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to @user, :notice => "Successfully created user."
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    
    redirect_to edit_user_path(@current_user) if @user != @current_user && !@current_user.admin?
  end

  def update
    @user = User.find(params[:id])
    
    # Only an admin may update another user.
    unless @current_user.admin? || @current_user == @user
      redirect_to surveys_path
      return
    end
    
    
    if @user.update_attributes(filtered_params(params[:user])))
      redirect_to (@current_user.admin? ? users_path : surveys_path), :notice  => "Successfully updated user."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "Successfully deleted user."
  end

private
  def filtered_params(user_attributes)
    @current_user.admin? ? user_attributes : user_attributes.except("role_id", "site_ids")
  end
end
