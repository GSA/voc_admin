CommentToolApp::Application.routes.draw do
  resources :raw_responses
  resources :surveys
  resources :survey_versions do
    resources :text_questions
    resources :choice_questions
    resources :survey_elements
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "surveys#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
