CommentToolApp::Application.routes.draw do
  match '/exports/:id/download' => "exports#download",
    :as => 'exports_download'

  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  get 'reset_password' => 'user_sessions#reset_password',
    :as => :reset_password
  resources :user_sessions, only: [:new, :create, :destroy] do
    post :do_pw_reset, :on => :collection
  end

	resources :users
	resources :sites

  resources :surveys

  resources :survey_responses,
    only: [:create, :index, :edit, :update, :destroy] do
      get :export_all, :on => :collection, :as => 'export_all'
  end

  resources :rules do
    get :do_now, :on => :member
    get :check_do_now, :on => :collection
  end
  resources :surveys do
    resources :survey_versions,
      only: [:show, :edit, :update, :destroy, :index] do
      get :publish, :on => :member, :as => "publish"
      get :unpublish, :on => :member, :as => "unpublish"
      get :clone_version, :on => :member, :as => "clone"
      get :edit_thank_you_page, :on => :member, :as => "edit_thank_you_page"

      resources :rules do
        put :increment_rule_order, :on => :member
        put :decrement_rule_order, :on => :member
        get :do_now, :on => :member
      end

      resources :display_fields,
        only: [:new, :create, :edit, :update, :destroy, :index] do
        put :increment_display_order, :on => :member
        put :decrement_display_order, :on => :member
      end

      resources :display_field_values, only: [:edit, :update]
      resources :custom_views,
        only: [:new, :create, :edit, :update, :destroy, :index]
      resources :custom_views
      resources :text_questions
      resources :choice_questions,
        only: [:new, :create, :edit, :update, :destroy]
      resources :matrix_questions,
        only: [:new, :create, :edit, :update, :destroy]

      # We don't need any default routes for survey_elements
      resources :survey_elements, only: [] do
        post :up, :on => :member
        post :down, :on => :member
      end

      resources :pages, only: [:create, :update, :destroy] do
        post :move_page, :on => :member
        post :copy_page, :on => :member
      end

      resources :assets,
       only: [:new, :create, :edit, :update, :destroy]
      get :create_new_major_version, :on => :collection
      get :create_new_minor_version, :on => :member

      # Reporting routes, currently disabled for HHS:
      # ---------------------------------------------
      # get :reporting, :on => :member
      # resources :dashboards
      # get "/dashboards/pdf/:id(.:format)" => "dashboards#pdf", :as => "pdf_dashboard"
      # resources :reports do
      #   resources :recurring_reports, :except => :show
      #   member do
      #     post :email_csv
      #     post :email_pdf
      #     get "/:reporter_type/:reporter_id.:format" => "reports#question_csv", :as => "question_csv"
      #   end
      # end
      # get "/reports/pdf/:id(.:format)" => "reports#pdf", :as => "pdf_report"
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

  # This is a legacy wild controller route that's not recommended for RESTful
  # applications.
  # Note: This route will make all actions in every controller accessible via
  # GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
