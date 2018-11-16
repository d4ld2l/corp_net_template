def draw_api_v0_routes
  namespace 'v0', defaults: {format: 'json'} do
    mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
        sessions: 'token_auth/sessions'
    }
    get '/', to: 'home#index' #, as: 'root'
    get 'birth_dates/nearest', to: 'birth_dates#nearest'
    resources :birth_dates, param: :birthday, only: %i[show index], defaults: {format: 'json'}
    post '/save_both', to: 'similar_candidates#save_both', as: :save_both
    post '/save_one', to: 'similar_candidates#save_one', as: :save_one
    resources :event_participants, only: :index, defaults: {format: 'json'}
    resources :email_notifications, only: :create
    post '/candidate_ratings', to: 'candidate_ratings#create', as: :create_candidate_rating
    post '/candidate_vacancies/:id/comments', to: 'candidate_vacancy_comments#create', as: :add_comment_to_candidate
    get '/candidate_vacancies/:id/comments', to: 'candidate_vacancy_comments#index', as: :show_comments_of_candidate
    delete '/candidate_vacancies/:id/comments/:comment_id', to: 'candidate_vacancy_comments#destroy', as: :delete_comment_of_candidate

    get 'mentions', to: 'mentions#index'

    get 'visits/stats', to: 'visits#stats'

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

    concern :nested_commentable do
      resources :comments
    end

    concern :nested_likable_commentable do
      resources :comments, concerns: [:likable]
    end

    concern :favoritable do
      member do
        post :to_favorites
        delete :from_favorites
      end
    end

    concern :likable do
      member do
        post :like
        delete :unlike
        get :likes
      end
    end

    concern :dictionariable do
      collection do
        get :dictionary
      end
    end

    get :settings, to: 'settings#index'
    get :login_settings, to: 'login_settings#index'

    scope module: 'resources' do
      namespace 'assessment' do
        resources :sessions, only: [:index, :show] do
          member do
            get :result
            post :send_reminders
            get :build
          end
          resources :evaluations, only: [:create]
        end
      end
      resources :accounts, except: %i[new edit], concerns:[:dictionariable] do
        collection do
          get :me
          get :get_ticket
          get :export_hr
          post :update_password
          patch 'update_password', as: :password_update_with_confirmation
          post 'generate_new_password_email', as: :reset_password_instructions
          post 'reset_password', as: :reset_password_via_token
        end
        member do
          get :fullness
        end
        resources :transactions, only: [:index]
        resources :account_photos, concerns: [:likable] do
          member do
            put :set_as_avatar
          end
        end
      end
      resources :comments, concerns: [:likable], except: %i[create index]
      post '/send_resume_letters', to: 'vacancies#send_letters', as: :send_resume_letters
      resources :candidates, except: %i[new edit], concerns:[:dictionariable] do
        collection do
          post :parse_file
        end
      end
      resources :personal_notifications, only: :index
      put '/personal_notifications/mark_as_read', to: 'personal_notifications#mark_as_read'
      resources :feed, except: %i[new edit], concerns: %i[likable favoritable nested_likable_commentable]
      resources :companies, except: %i[new edit]
      # get 'profiles/me', to: 'profiles#me'
      # get 'profiles/:id/fullness', to: 'profiles#fullness'
      # post 'profiles/update_password', to: 'profiles#update_password', as: :password_update
      # get 'profiles/hr', to: 'profiles#index_hr'
      # get 'profiles/export_hr', to: 'profiles#export_hr'
      # resources :profiles, except: %i[new edit] do
      #   member do
      #     get :hr, to: 'profiles#show_hr'
      #   end
      #   resources :transactions, only: [:index]
      # end
      resources :skills, only: [:index], concerns: [:dictionariable]
      resources :account_skills, except: %i[new edit] do
        member do
          put :confirm
          patch :confirm
          delete :unconfirm
        end
      end
      resources :customers, except: [:new, :edit] do
        resources :customer_contacts, path: :contacts, concerns: [:commentable] do
          collection do
            get :as_xlsx
          end
        end
      end
      resources :projects, except: [:new, :edit], concerns:[:dictionariable] do
        resources :account_projects do
          member do
            post :repair
          end
        end
      end
      resources :account_projects, except: [:new, :edit]
      resources :roles, except: [:new, :edit]
      get ':entity_type/:entity_id/tasks/', to: 'tasks#index'
      post ':entity_type/:entity_id/tasks/', to: 'tasks#create'
      get ':entity_type/:entity_id/tasks/:id', to: 'tasks#show'
      resources :tasks, only: [:create, :update, :show, :index, :destroy] do
        resources :subtasks, only: [:create, :update, :show, :destroy, :index]
      end
      get 'permissions/my', to: 'permissions#my'
      get 'departments/tree'
      resources :departments, except: %i[new edit]
      get 'vacancies/destination_search', to: 'vacancies#destination_search', as: :vacancy_destination_search
      get 'vacancies/stats', to: 'vacancies#stats', as: :vacancies_stats
      resources :vacancies, except: %i[new edit], concerns: [:dictionariable, :aasm_states] do
        resources :candidates, controller: 'candidate_vacancies', except: %i[new edit], concerns:[:dictionariable] do
          collection do
            put :transfer
          end
        end
        member do
          get :vacancy_stages
        end
      end
      resources :template_stages, except: %i[new edit]
      resources :news, except: %i[new edit], concerns: %i[aasm_states likable nested_likable_commentable]
      resources :news_groups, except: %i[new edit]
      resources :candidate_vacancies, except: %i[new edit]
      resources :vacancy_stage_groups, only: [] do
        collection do
          get :stats
          get :recruitment_vortex
        end
      end
      resources :survey_results, only: %i[create show]
      resources :surveys
      resources :mailing_lists
      get 'surveys/:id/download', to: 'surveys#download', as: :survey_download
      resources :events, except: %i[edit new]
      get 'dictionaries/:dictionary_name', to: 'dictionaries#index'
      get 'services', to: 'service_groups#index'
      resources :services, only: %i[show], concerns: %i[aasm_states]
      resources :bids, except: %i[edit new], concerns: %i[aasm_states commentable] do
        resources :team_building_information_accounts, only: :index
        collection do
          get :author
          get :executor
          post :import
        end
        member do
          get :build
        end
      end
      resources :legal_units, only: %i[index show], concerns:[:dictionariable]
      # get 'discussions/filters', to: 'discussions#filters'
      get ':entity_type/:entity_id/discussions/', to: 'discussions#index'
      post ':entity_type/:entity_id/discussions/', to: 'discussions#create'
      get ':entity_type/:entity_id/discussions/:id', to: 'discussions#show'
      resources :discussions, except: %i[new edit destroy], concerns: %i[likable] do
        collection do
          get :filters
          get :counters
          delete :destroy
          put :close
          put :open
          post :to_favorites
          delete :from_favorites
        end
        member do
          put :mark_as_read
          put :mark_all_as_read
          delete :leave
          delete :remove_discussers
          post :join
          post :add_discussers
        end
        resources :comments, controller: 'discussion_comments', concerns: :likable, except: %i[new edit]
      end
      get :components, to: 'components#index'
    end
  end
  match "*path", to: "base#catch_404", via: :all
end


constraints subdomain: 'api', constraints: {format: 'json'} do
  scope module: 'api' do
    draw_api_v0_routes
  end
end


namespace 'api' do
  draw_api_v0_routes
end