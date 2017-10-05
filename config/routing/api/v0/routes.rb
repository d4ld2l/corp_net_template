def draw_api_v0_routes
  namespace 'v0', defaults: { format: 'json' } do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      sessions:  'token_auth/sessions'
    }
    get '/', to: 'home#index'#, as: 'root'
    get 'birth_dates/nearest', to: 'birth_dates#nearest'
    resources :birth_dates, param: :birthday, only: %i[show index], defaults: { format: 'json' }

    resources :event_participants, only: :index, defaults: { format: 'json' }

    concern :aasm_states do
      member do
        get :allowed_states
        get :states
        put 'change_state/:state', action: :change_state
        patch 'change_state/:state', action: :change_state
      end
    end

    concern :commentable do
      member do
        post :add_comment
      end
    end

    scope module: 'resources' do
      resources :users_admin, :controller => 'users', except: [:new, :edit]
      resources :companies, except: [:new, :edit]
      resources :communities, except: [:new, :edit]
      get 'profiles/me', to: 'profiles#me'
      resources :profiles, except: [:new, :edit]
      resources :offices, except: [:new, :edit]
      resources :customers, except: [:new, :edit]
      resources :projects, except: [:new, :edit]
      resources :user_projects, except: [:new, :edit]
      resources :roles, except: [:new, :edit]
      get 'permissions/my', to: 'permissions#my'
      get 'departments/tree'
      resources :departments, except: [:new, :edit]
      resources :news, except: [:new, :edit], concerns: [:commentable, :aasm_states]
      resources :news_categories, except: [:new, :edit]
      resources :news_groups, except: [:new, :edit]
      resources :events, except: [:edit, :new]
      get 'dictionaries/:dictionary_name', to: 'dictionaries#index'
    end
  end
end

constraints subdomain: 'api', constraints: { format: 'json' } do
  scope module: 'api' do
    draw_api_v0_routes
  end
end

namespace 'api' do
  draw_api_v0_routes
end