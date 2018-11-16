class Api::V0::Resources::VacanciesController < Api::ResourceController
  include AasmStates
  before_action :set_creator, only: [:create]

  def stats
    chain = resource_collection
    chain = if vacancy_scope
              vacancy_scope == 'all' ? chain.all : chain.send(vacancy_scope, current_account.id)
            else
              chain.as_creator_or_owner(current_account.id)
            end
    res = Vacancy.aasm.states.map { |s| [s.to_s, 0] }.to_h
    res.merge!(chain.select(%i[status id]).group([:status]).count(:id))
    render json: res
  end

  def dictionary
    result = Vacancy.all
    result = if vacancy_scope
               vacancy_scope == 'all' ? result.all : result.send(vacancy_scope, current_account.id)
             else
               result.as_creator_or_owner(current_account.id)
             end
    result = result.where(status: vacancy_status) if vacancy_status
    render json: result.order(:created_at).select(:id, :name, :creator_id, :owner_id).as_json(
      only: %i[id name creator_id owner_id]
    )
  end

  def send_letters
    if params[:to].blank?
      render json: { success: false, errors: 'Поле "Кому" является обязательным' }
    else
      ResumeMailer.send_email(params[:candidates_ids] || [], params[:to] || [], params[:copy] || [], params[:subject] || '', params[:body] || '', params[:attachments].as_json || [], current_account.id).deliver_later
      DchResumeNotificationsWorker.perform_async(
        params[:candidates_ids] || [],
        params[:to] || [],
        params[:copy] || [],
        params[:body] || '',
        params[:attachments].as_json || []
      )

      render json: { success: true }
    end
  end

  def vacancy_stages
    @vacancy = Vacancy.includes(vacancy_stages: :vacancy_stage_group).find(params[:id])
    render json: vs_merge(@vacancy).as_json(
      only: [],
      include: {
        vacancy_stages: {
          only: %i[id name evaluation_of_candidate],
          include:
            {
              vacancy_stage_group: {
                only: %i[id label color value]
              }
            },
          methods: %i[candidates_count rated unrated]
        }
      }
    )
  end

  private

  def set_creator
    @resource_instance.creator ||= current_account
  end

  def association_chain
    result = resource_collection.includes(chain_collection_inclusion)
    result = if vacancy_scope
               vacancy_scope == 'all' ? result.all : result.send(vacancy_scope, current_account.id)
             else
               result.as_creator_or_owner(current_account.id)
             end
    result = result.where(status: vacancy_status) if vacancy_status
    result.default_order.page(page).per(per_page)
  end

  def vacancy_scope
    @scope ||= params[:scope] if %w[all as_creator as_owner as_creator_or_owner as_manager].include?(params[:scope])
  end

  def vacancy_status
    @status ||= params[:status].split(',') if params[:status]&.split(',')&.all? { |x| Vacancy.aasm.states.map(&:name).include?(x&.to_sym) }
  end

  def permitted_attributes
    [:name, :positions_count, :demands, :duties, :type_of_salary, :owner_id, :creator_id,
     :level_of_salary_from, :level_of_salary_to, :show_salary,
     :type_of_contract, :place_of_work, :comment, :manager, :manager_id,
     :legal_unit, :practice, :block, :project,
     :ends_at, :comment_for_employee, :status,
     :additional_tests, :file, :reason_for_opening, :current_stage,
     documents_attributes: %i[id file name _destroy],
     candidate_vacancies_attributes: %i[id candidate_id current_vacancy_stage_id],
     vacancy_stages_attributes: %i[id vacancy_stage_group_id name must_be_last position
                                   need_notification evaluation_of_candidate editable can_create_left
                                   can_create_right type_of_rating _destroy],
     account_vacancies_attributes: %i[id account_id _destroy],
     experience: [], schedule: [], type_of_employment: []]
  end

  def vs_merge(resource)
    ratings = resource.count_ratings_by_stages
    unrated = resource.count_unrated_by_stages
    resource.vacancy_stages.each do |vs|
      vs.rated = ratings[vs.id] || {}
      vs.unrated = unrated[vs.id] || 0
    end
    resource
  end

  def set_resource
    super
    vs_merge(@resource_instance)
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      include: {
        creator: {
          only: %i[id photo],
          methods: :name_surname
        },
        vacancy_stages: {
          only: %i[id name],
          include:
            {
              vacancy_stage_group: {
                only: %i[id label color value]
              }
            },
          methods: [:candidates_count]
        }
      },
      only: %i[id name created_at place_of_work status],
      methods: %i[status_name]
    }
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= {
      methods: %i[ status_name ],
      include: {
        documents: {},
        account_vacancies: {
          only: :id,
          include: {
            account: {
              only: %i[id photo],
              methods: %i[position_name name_surname email_address full_name]
            }
          }
        },
        owner: {
          only: :id,
          methods: :name_surname
        },
        creator: {
          only: %i[id photo],
          methods: %i[name_surname email_address]
        },
        vacancy_stages: {
          include: {
            vacancy_stage_group: { only: %i[id label color value] }
          },
          methods: %i[candidates_count rated unrated]
        }
      }
    }
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= [:documents, :creator, :owner, vacancy_stages: :vacancy_stage_group, account_vacancies: [account: [default_legal_unit_employee: [legal_unit_employee_position: :position]]]]
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [:creator, vacancy_stages: :vacancy_stage_group]
  end
end
