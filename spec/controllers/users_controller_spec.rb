require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  
  render_views
  
  def valid_attributes
    {:email => "jalvarado@ctacorp.com", :password => "password", :password_confirmation => "password", :f_name => "juan", :l_name => "alvarado", :role_id => Role::ADMIN}
  end

  context "with an unauthenticated user" do
      it "should deny index" do
        get :index
        response.should redirect_to(login_url)
        flash.should have_key(:error)
      end
  end

  context "with a logged in user" do
    include Authlogic::TestCase

    before do
      activate_authlogic

      @user1 = User.create(:email => "jalvarado@ctacorp.com", :password => "password", :password_confirmation => "password", :f_name => "juan", :l_name => "alvarado")
      @user2 = User.create(:email => "jvose@ctacorp.com", :password => "password", :password_confirmation => "password", :f_name => "jake", :l_name => "vose")
    end

    context "when a regular user" do
      before do
        UserSession.create @user1
      end

      it "should deny index" do
        get :index
        response.should redirect_to(surveys_path)
        flash.should have_key(:error)
      end

      it "should deny show" do
        get :show, :id => @user1
        response.should redirect_to(surveys_path)
        flash.should have_key(:error)
      end

      it "should deny new" do
        get :new
        response.should redirect_to(surveys_path)
        flash.should have_key(:error)
      end

      it "should deny create" do
        User.any_instance.stub(:valid?).and_return(true)
        post :create, :user => valid_attributes
        response.should redirect_to(surveys_path)
        flash.should have_key(:error)
      end

      it "should allow a user to edit own profile" do
        get :edit, :id => @user1
        response.should render_template(:edit)
      end

      it "should prevent a user from editing another user's profile" do
        get :edit, :id => @user2
        response.should redirect_to(edit_user_path(@user1))
      end

      it "should render edit template on update when model is invalid" do
        User.any_instance.stub(:valid?).and_return(false)
        put :update, :id => @user1, :user => { :fname => "justin" }
        response.should render_template(:edit)
      end

      it "should allow self update when model is valid" do
        User.any_instance.stub(:valid?).and_return(true)
        put :update, :id => @user1, :user => { :fname => "justin" }
        response.should redirect_to(surveys_path)
        flash.should_not have_key(:error)
      end

      it "should prevent a user from updating another user's profile" do
        put :update, :id => @user2, :user => { :fname => "justin" }
        response.should redirect_to(surveys_path)
      end

      it "should deny destroy" do
        delete :destroy, :id => @user1
        response.should redirect_to(surveys_path)
        User.exists?(@user1).should be_true
        flash.should have_key(:error)
      end

    end

    context "when an admin user" do
      before do
        @user1.role_id = Role::ADMIN
        UserSession.create @user1
      end

      it "index action should render index template" do
        get :index
        response.should render_template(:index)
      end

      it "show action should render show template" do
        get :show, :id => @user2
        response.should render_template(:show)
      end

      it "new action should render new template" do
        get :new
        response.should render_template(:new)
      end

      it "create action should render new template when model is invalid" do
        User.any_instance.stub(:valid?).and_return(false)
        post :create
        response.should render_template(:new)
      end

      it "create action should redirect when model is valid" do
        User.any_instance.stub(:valid?).and_return(true)
        post :create, :user => valid_attributes
        response.should redirect_to(user_url(assigns[:user]))
      end

      it "edit action should render edit template" do
        get :edit, :id => @user2
        response.should render_template(:edit)
      end

      it "should render edit template on update when model is invalid" do
        User.any_instance.stub(:valid?).and_return(false)
        put :update, :id => @user2, :user => { :fname => "justin" }
        response.should render_template(:edit)
      end

      it "should allow update when model is valid" do
        User.any_instance.stub(:valid?).and_return(true)
        put :update, :id => @user2, :user => { :fname => "justin" }
        response.should redirect_to(users_path)
      end

      it "destroy action should destroy model and redirect to index action" do
        delete :destroy, :id => @user2
        response.should redirect_to(users_url)
        User.exists?(@user2).should be_false
      end
    end
  end

end
