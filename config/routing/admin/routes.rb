# curl -X POST -D - -F 'email=admin@admin.com' -F 'password=123456' http://localhost:3000/api/v1/auth/sign_in
# token auth routes available at /api/v1/auth
scope module: 'admin' do
  root 'home#index'
  post 'set_tenant', to: 'home#set_tenant', as: :set_tenant
  get 'fallback', to: 'home#fallback', as: :fallback

  scope module: 'resources' do
    concern :importable do
      collection do
        post :import
        post :confirm_import
        get :confirm_import
        post :create_from_imported
      end
    end
    require 'sidekiq/web'
    require 'sidekiq/cron/web'
    require 'sidekiq/grouping/web'
    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
    authenticate :account, lambda { |a| a.role? :admin } do
      mount Sidekiq::Web => '/sidekiq'
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

    concern :blockable do
      member do
        post :to_blocked
        post :to_active
      end
    end

    resources :accounts, controller: :accounts, concerns: [:autocompletes, :importable, :blockable] do
      member do
        get 'show_account_position', to: 'accounts#show_account_position', as: 'show_account_position'
      end
    end
    resources :companies do
      member do
        post :make_default
      end
    end
    resources :offices
    resources :skills
    resources :resumes
    resources :resume_experiences
    resources :resume_skills
    resources :resume_sources
    resources :contract_types
    resources :customers
    resources :projects
    resources :account_projects
    resources :roles
    resources :permissions
    resources :education_levels
    resources :position_groups
    resources :positions
    resources :departments do
      collection do
        post :import
        get :as_csv
      end
    end
    resources :events
    resources :event_types
    resources :admin_settings, only: [:index, :edit, :update, :show]
    resources :settings
    resources :settings_groups
    resources :ui_settings
    resources :components, except:[:destroy, :new, :create] do
      member do
        post :toggle
      end
    end
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
        get :account_index
        get :render_form
        get :search_news_by_tag
      end

      resources :topics, swallow: true do
        member do
          post :create_message
        end
      end
    end

    resources :mailing_lists
    resources :notifications
    resources :comments
    resources :news_items, concerns: [:publishable, :commentable]
    resources :news_categories
    resources :professional_areas
    resources :languages
    resources :language_levels
    resources :legal_units do
      member do
        get :edit_employees
        patch :update_employees
      end
    end

    scope module: :assessment do
      resources :project_roles, as: :assessment_project_roles
      resources :sessions, as: :assessment_sessions do
        member do
          put 'change_state/:state', action: :change_state, as: 'change_state'
          post :send_reminders
          get :build
        end
        collection do
          get :as_xlsx
        end
      end
    end

    resources :surveys do
      member do
        post :publish
        post :unpublish
        post :archived
      end

      resources :survey_results, only: [:show, :index] do
        collection do
          get :download
        end
      end
    end
    resources :vacancies
    resources :candidates, only: [:index, :show, :destroy] do
      member do
        get :info360
      end
    end

    get 'account/my', to: 'accounts#my', as: :my_account
    get 'account/export', to: 'accounts#export', as: :export_accounts
    # post 'account/import', to: 'accounts#import', as: :accounts_import
    get 'account/edit_password', to: 'accounts#edit_password', as: :password_edit
    post 'projects/:id/to_mailing_list', to: 'projects#to_mailing_list', as: :project_to_mailing_list
    post 'departments/:id/to_mailing_list', to: 'departments#to_mailing_list', as: :department_to_mailing_list
    post 'account/update_password', to: 'accounts#update_password', as: :password_update
    post 'account/send_email', to: 'accounts#send_email'

    resources :bids do#, except: %i[new create] do
      member do
        get :build
      end
      collection do
        get :byod_report
        get :representation_allowance_report
        post :import
      end
    end
    resources :services, concerns: :publishable
    resources :service_groups
    resources :bid_stages_groups
    resources :bids_executors
    resources :achievements, except:[:new, :create, :destroy]
    resources :achievement_groups
    resources :transactions
  end
  get 'all_settings', to: 'all_settings#index'
  get 'chat', to: 'chat#index', as: :chat
  get 'server_administration', to: 'server_administration#index', as: :server_administration
  get 'server_administration/elastic_reindex', to: 'server_administration#reindex', as: :reindex_elasticsearch
end
