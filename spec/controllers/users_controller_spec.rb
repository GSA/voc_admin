require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  include Authlogic::TestCase

  setup :activate_authlogic


  context "no user logged in" do
    it "should redirect to the login page" do
      get :index
      response.should redirect_to(login_path)
    end
  end

  context "user is logged in" do
    before(:each) do
      @user = create(:user, :admin)
      controller.stub(:current_user).and_return @user
    end

    it "should render the index template" do
      get :index
      response.status.should == 200
      response.should render_template(:index)
    end

    it "show action should render show template" do
      get :show, :id => @user.id
      response.should render_template(:show)
    end

    it "new action should render new template" do
      get :new
      response.should render_template(:new)
    end

    it "create action should render new template when model is invalid" do
      User.any_instance.stub(:valid?).and_return false

      post :create
      response.should render_template(:new)
    end

    it "create action should redirect when model is valid" do
      post :create, :user => {
        email: "user@example.com",
        password: "password",
        password_confirmation: "password",
        f_name: "user",
        l_name: "test"
      }

      user = assigns(:user)
      user.should_not be_nil
      response.should redirect_to(user)
    end

    it "edit action should render edit template" do
      get :edit, :id => @user
      response.should render_template(:edit)
    end

    it "update action should render edit template when model is invalid" do
      User.any_instance.stub(:update_attributes).and_return false
      put :update, :id => @user, :user => {:email => ""}
      response.should render_template(:edit)
    end

    it "update action should redirect to user when model is valid" do
      put :update, :user => { :f_name => "Test 2" }, :id => @user.id
      response.should redirect_to(users_path)
    end
  end # user is logged in

end
