module Componentable
  extend ActiveSupport::Concern
  
  included do
    before_action :check_enabled

    private

    def check_enabled
      unless enabled_controllers.include? controller_name
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def enabled_controllers
      controllers = []
      current_tenant.enabled_components.map{|x| x['name']}.each do |n|
        controllers += mapping[n.to_sym] || []
      end
      controllers += mapping[:common]
      controllers.compact.uniq
    end

    def mapping
      @mapping ||= {
          shr_core:[ 'profiles', 'accounts', 'permissions', 'users', 'birth_dates', 'home', 'components', 'visits', 'birth_dates', 'offices', 'account_photos' ],
          shr_bids:[ 'bids', 'bid_stages_groups', 'bids_executors', 'team_building_information_accounts' ],
          shr_calendar:[ 'events', 'event_types', 'event_participants' ],
          shr_communities:[ 'communities', 'topics' ],
          shr_discussions:[ 'discussions', 'discussion_comments', 'comments', 'mentions' ],
          shr_feed:[ 'feed', 'mentions', 'comments' ],
          shr_game:[ 'achievements', 'achievement_groups', 'transactions' ],
          shr_news:[ 'news', 'news_categories', 'news_items',  ],
          shr_org:[ 'accounts', 'departments', 'legal_units', 'position_groups', 'positions' ],
          shr_projects:[ 'projects', 'account_projects', 'customer_contacts', 'customers', 'project_roles' ],
          shr_resume:[ 'resumes', 'education_levels', 'professional_areas', 'resume_experiences', 'resume_sources', 'languages', 'language_levels'],
          shr_services:[ 'services', 'service_groups', ],
          shr_skills:[ 'skills', 'account_skills' ],
          shr_surveys:[ 'surveys', 'survey_results',  ],
          shr_tasks:[ 'tasks', 'subtasks' ],
          shr_teams:[ 'mailing_lists' ],
          shr_data_storage:[],
          recruitment_core:[ 'vacancies', 'candidates', 'candidate_vacancies',
                             'template_stages', 'vacancy_stage_groups', 'candidate_ratings',
                             'candidate_vacancy_comments', 'similar_candidates', 'professional_areas', 'languages',
                             'language_levels', 'resume_sources', 'resume_experiences', 'education_levels',
                             'resume_skills', 'contract_types'
          ],
          recruitment_tasks:[ 'tasks', 'subtasks' ],
          common: [ 'dictionaries', 'components', 'companies',
                    'permissions', 'personal_notifications',
                    'email_notifications', 'server_administration',
                    'admin_settings', 'notifications', 'roles',
                    'settings', 'sessions', 'ui_settings', 'settings_groups',
                    'all_settings', 'auth', 'accounts'
          ],
          rocket_chat: [],
          head_menu: [],
          shr_personnel: [],
          shr_assessment: ['sessions', 'evaluations']
      }
    end
  end
end
