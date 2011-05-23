CommentToolApp::Application.routes.draw do
  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  resources :user_sessions
  
  resources :users

  resources :surveys

  resources :categories
  resources :survey_responses
  resources :raw_responses
  resources :rules do
    get :do_now, :on => :member
    get :check_do_now, :on => :collection
  end
  resources :surveys do
    resources :survey_versions do
      get :publish, :on => :member, :as => "publish"
      resources :rules do
        get :do_now, :on => :member
      end
      resources :display_fields
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
      end
      resources :assets
      get :create_new_major_version, :on => :collection
      get :create_new_minor_version, :on => :member
    end
  end
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "surveys#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
