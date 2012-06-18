CommentToolApp::Application.routes.draw do
  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  get 'reset_password' => 'user_sessions#reset_password', :as => :reset_password
  resources :user_sessions do
    post :do_pw_reset, :on => :collection
  end
  
	resources :users
	resources :sites
	
  resources :surveys

  resources :categories
  resources :survey_responses do
    get :export_all, :on => :collection, :as => 'export_all'
  end
  resources :raw_responses
  resources :rules do
    get :do_now, :on => :member
    get :check_do_now, :on => :collection
  end
  resources :surveys do
    resources :survey_versions do
      get :publish, :on => :member, :as => "publish"
      get :unpublish, :on => :member, :as => "unpublish"
      get :clone_version, :on => :member, :as => "clone"
      resources :rules do
        put :increment_rule_order, :on => :member
        put :decrement_rule_order, :on => :member
        get :do_now, :on => :member
      end
      resources :display_fields do
        put :increment_display_order, :on => :member
        put :decrement_display_order, :on => :member
      end
      resources :display_field_values
      resources :text_questions
      resources :choice_questions
      resources :matrix_questions
      resources :survey_elements do
        post :up, :on => :member
        post :down, :on => :member
      end
      resources :pages do
        post :move_page, :on => :member
        post :copy_page, :on => :member
      end
      resources :assets
      get :create_new_major_version, :on => :collection
      get :create_new_minor_version, :on => :member
    end
  end
  
  resources :images do
    get :display, :on => :collection
    delete :remove, :on => :collection
    post :save_file, :on => :collection
  end
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "user_sessions#new"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
