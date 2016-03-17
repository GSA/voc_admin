# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Manages the lifecycle of User entities. A User may edit his/her
# own profile, but the remainder of functionality is reserved for admins.
class UsersController < ApplicationController
  before_filter :require_admin, :except => [:edit, :update]
  # GET    /users(.:format)
  def index
    @users = User.includes(:organization).search(params[:q])

    if params[:sort]
      @users = @users.order("#{sort_column} #{sort_direction}")
    end

    @users = @users.listing
    @users = @users.page(params[:page]).per(10)

    if @users.count == 0 && params[:q].present?
      flash.now[:notice] = "No users were found with search."
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET    /users/:id(.:format)
  def show
    @user = User.find(params[:id])
  end

  # GET    /users/new(.:format)
  def new
    @user = User.new
  end

  # POST   /users(.:format)
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, :notice => "Successfully created user." }
        format.js
      else
        format.html { render :action => 'new' }
        format.js
      end
    end
  end

  # GET    /users/:id/edit(.:format)
  def edit
    @user = User.find(params[:id])

    redirect_to edit_user_path(current_user) if @user != current_user && !current_user.admin?
  end

  # PUT    /users/:id(.:format)
  def update
    @user = User.find(params[:id])

    # Only an admin may update another user.
    unless current_user.admin? || current_user == @user
      redirect_to surveys_path
      return
    end

    respond_to do |format|
      if @user.update_attributes(filtered_params(params[:user]))
        format.html {redirect_to (current_user.admin? ? users_path : surveys_path), :notice  => "Successfully updated user."}
        format.js
      else
        format.html {render :action => 'edit'}
        format.js
      end
    end
  end

  # DELETE /users/:id(.:format)
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, :notice => "Successfully deleted user."
  end

  private
  
  # Modifies the fields available to non-admin users for edit.
  #
  # @param [Hash] user_attributes the PUT parameters from the update operation
  # @return [Hash] the same Hash with Role and Site information removed for non-admin edits.
  def filtered_params(user_attributes)
    current_user.admin? ? user_attributes : user_attributes.except("role_id", "site_ids")
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "role_id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
