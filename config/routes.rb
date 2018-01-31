CommentToolApp::Application.routes.draw do
  devise_for :users,
             controllers: { omniauth_callbacks: "users/omniauth_callbacks", sessions: "sessions" },
             timeout_in: ENV.fetch('SESSION_TIMEOUT').to_i.minutes

  get '/exports/:id/download' => 'exports#download', :as => 'exports_download'

  devise_scope :user do
    match '/users/auth/:action/callback', to: 'users/omniauth_callbacks', via: [:get, :post]
    get 'sign_in', to: 'devise/sessions#new', as: :new_user_session
    get 'sign_out', :to => 'sessions#destroy', :as => :destroy_user_session

  resources :users
  resources :sites
  resources :organizations

  resources :surveys do
    get :preview, on: :collection
    get :start_page_preview, on: :member
    get :all_questions, on: :collection
    post 'import_survey_version'
  end

  resource :question_bank do
    resources :text_questions, controller: 'question_bank/text_questions'
    resources :choice_questions, controller: 'question_bank/choice_questions'
    resources :matrix_questions, controller: 'question_bank/matrix_questions'
    post :add_question_to_survey, collection: true, as: 'add_question_from'
  end

  resources :survey_responses,
            only: [:create, :index, :edit, :update, :destroy] do
    get :export_csv, on: :collection, as: 'export_csv'
    get :export_xls, on: :collection, as: 'export_xls'
  end

  resources :rules do
    get :do_now, on: :member
    get :check_do_now, on: :collection
  end
  resources :surveys do
    resources :survey_versions,
              only: [:show, :edit, :update, :destroy, :index] do
      get :publish, on: :member, as: 'publish'
      get :unpublish, on: :member, as: 'unpublish'
      get :clone_version, on: :member, as: 'clone'
      get :edit_thank_you_page, on: :member, as: 'edit_thank_you_page'
      get :edit_notes, on: :member, as: :edit_notes
      get :export_survey, on: :collection, as: 'export_survey'
      get :preview, on: :member
      resources :saved_searches, only: [:index, :create, :destroy]

      resources :rules do
        put :increment_rule_order, on: :member
        put :decrement_rule_order, on: :member
        get :do_now, on: :member
      end

      resources :display_fields,
                only: [:new, :create, :edit, :update, :destroy, :index] do
        put :increment_display_order, on: :member
        put :decrement_display_order, on: :member
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
        post :up, on: :member
        post :down, on: :member
      end

      resources :pages, only: [:create, :update, :destroy] do
        post :move_page, on: :member
        post :copy_page, on: :member
      end

      resources :assets,
                only: [:new, :create, :edit, :update, :destroy]
      get :create_new_major_version, on: :collection
      get :create_new_minor_version, on: :member

      # Reporting routes, currently disabled for HHS:
      # ---------------------------------------------
      get :reporting, on: :member
      resources :dashboards
      get '/dashboards/pdf/:id(.:format)' => 'dashboards#pdf', :as => 'pdf_dashboard'
      resources :reports do
        resources :recurring_reports, except: :show
        member do
          post :email_csv
          post :email_pdf
          get '/:reporter_type/:reporter_id.:format' => 'reports#question_csv', :as => 'question_csv'
        end
      end
      get '/reports/pdf/:id(.:format)' => 'reports#pdf', :as => 'pdf_report'
    end
  end
end
  resources :images do
    get :display, on: :collection
    delete :remove, on: :collection
    post :save_file, on: :collection
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root to: 'surveys#index'
end
