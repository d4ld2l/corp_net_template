# curl -X POST -D - -F 'email=admin@admin.com' -F 'password=123456' http://localhost:3000/api/v1/auth/sign_in
# token auth routes available at /api/v1/auth
scope module: 'admin' do
  root 'home#index'
  # get 'persons/profile', as: 'user_root'

  scope module: 'resources' do
    concern :importable do
      collection do
        get :import
        post :confirm_import
        get :confirm_import
        post :create_from_imported
      end
    end

    concern :publishable do
      member do
        post :publish
        post :archive
        post :unpublish
        post :repair
      end
    end

    concern :commentable do
      member do
        post :add_comment
      end
    end

    concern :autocompletes  do
      collection do
        get :autocomplete
      end
    end

    resources :users_admin, controller: :users, concerns: [:autocompletes, :importable]
    resources :profiles, except: :index
    resources :companies
    resources :offices
    resources :customers
    resources :projects
    resources :user_projects
    resources :roles
    resources :permissions
    resources :departments
    resources :events
    resources :event_types
    resources :communities, concerns: :autocompletes do
      member do
        post :subscribe
        post :unsubscribe
        post :apply
        post :create_news
        put :update_news
        get :news_index
        put 'change_state/:state', action: :change_state, as: 'change_state'
        get :allowed_states
        get :user_index
        get :render_form
        get :search_news_by_tag
      end

      resources :topics, swallow: true do
        member do
          post :create_message
        end
      end
    end

    resources :notifications
    resources :comments
    resources :news_items, concerns: [:publishable, :commentable]
    resources :news_categories
    resources :legal_units do
      member do
        get :edit_employees
        patch :update_employees
      end
    end
    resources :position_groups
    resources :positions
    resources :project_roles

    get 'profile/my', to: 'profiles#my', as: :my_profile
    post 'profile/send_email', to: 'profiles#send_email'
  end
end
