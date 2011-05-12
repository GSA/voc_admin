CommentToolApp::Application.routes.draw do
  resources :categories
  resources :survey_responses
  resources :raw_responses
  resources :processed_responses
  resources :surveys do
    resources :survey_versions do
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
      resources :pages
      resources :assets
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
