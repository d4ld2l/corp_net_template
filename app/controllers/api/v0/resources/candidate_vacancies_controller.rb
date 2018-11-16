class Api::V0::Resources::CandidateVacanciesController < Api::ResourceController
  before_action :build_resource, only: []

  def index
    render json: { data: @collection.as_json(json_collection_inclusion), count: @count }
  end

  def create
    if params[:candidate_ids].blank?
      render json: { success: false, errors: 'Отсутствуют кандидаты в запросе' }
    else
      if CandidateVacancy.where(candidate_id: params[:candidate_ids], vacancy_id: params[:vacancy_id]).exists?
        render json: { success: false, errors: 'Один или несколько кандидатов уже привязаны к данной вакансии' }
      else
        if Candidate.ids & params[:candidate_ids].sort == params[:candidate_ids].sort
          CandidateVacancy.create(params[:candidate_ids].map { |x| { candidate_id: x, vacancy_id: params[:vacancy_id] } })
          render json: { success: true }
        else
          render json: { success: false, errors: 'Отсутствует один или несколько кандидатов в базе' }
        end
      end
    end
  end

  def transfer
    if params[:candidate_ids].blank?
      render json: { success: false, errors: 'Отсутствуют кандидаты в запросе' }
    elsif params[:stage_id].blank?
      render json: { success: false, errors: 'Отсутствует этап в запросе' }
    elsif (CandidateVacancy.where(vacancy_id: params[:vacancy_id]).pluck(:candidate_id) & params[:candidate_ids]).sort != params[:candidate_ids].sort
      render json: { success: false, errors: 'Один или несколько кандидатов не принадлежат вакансии' }
    else
      if CandidateVacancy.where(candidate_id: params[:candidate_ids], vacancy_id: params[:vacancy_id], current_vacancy_stage_id: params[:stage_id]).exists?
        render json: { success: false, errors: 'Один или несколько кандидатов уже на данном этапе' }
      else
        if (Candidate.ids & params[:candidate_ids]).sort == params[:candidate_ids].sort
          if (cv = CandidateVacancy.where(candidate_id: params[:candidate_ids], vacancy_id: params[:vacancy_id]).update(current_vacancy_stage_id: params[:stage_id]))
            if cv.map(&:errors).any? &:any?
              render(json: { success: false, errors: cv.map(&:errors).as_json })
            else
              render json: { success: true }
            end
          else
            render(json: { success: false, errors: cv.errors.as_json })
          end
        else
          render json: { success: false, errors: 'Отсутствует один или несколько кандидатов в базе' }
        end
      end
    end
  end

  private

  def association_chain
    result = resource_collection.includes(chain_collection_inclusion).where(vacancy_id: params[:vacancy_id]).order(created_at: :desc)
    if params[:vacancy_stage_id]
      result = result.where(current_vacancy_stage_id: params[:vacancy_stage_id]).joins('LEFT OUTER JOIN candidate_ratings ON candidate_ratings.id = (SELECT candidate_ratings.id FROM candidate_ratings WHERE candidate_vacancies.id = candidate_ratings.candidate_vacancy_id AND candidate_vacancies.current_vacancy_stage_id = candidate_ratings.vacancy_stage_id ORDER BY candidate_ratings.created_at DESC LIMIT 1)').reorder('CASE WHEN candidate_ratings.value = 1 THEN 1 WHEN candidate_ratings.value = 0 THEN -1 ELSE 0 END DESC, candidate_vacancies.created_at DESC')
    end
    @count = result.count
    result.page(page).per(per_page)
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      only: :id,
      include: {
        candidate: {
          include: {
            resume: {
              include: {
                preferred_contact: {
                  only: %i[id contact_type value]
                }
              },
              only: %i[city desired_position id photo salary_level],
              methods: :last_position
            }
          },
          methods: %i[full_name]
        },
        current_vacancy_stage: {
          include: {
            vacancy_stage_group: { only: %i[id label color value] }
          },
          only: %i[id name evaluation_of_candidate]
        },
        current_candidate_rating: {
          only: %i[id rating_type value],
          include: {
            commenter: {
              only: %i[id photo],
              methods: :full_name
            }
          }
        }
      },
      methods: [:next_vacancy_stage]
    }
  end


  def json_resource_inclusion
    @json_resource_inclusion ||= {
      only: :id,
      methods: %i[next_vacancy_stage candidate_changes_as_json other_vacancies_count],
      include: {
        candidate: {
          methods: %i[last_resume_action age full_name],
          include: {
            resume: {
              methods: %i[last_position],
              only: %i[city desired_position id photo raw_resume_doc salary_level],
              include: {
                preferred_contact: {
                  only: %i[id contact_type value]
                },
                resume_contacts: {},
                additional_contacts: {},
                last_work_experience: {}
              }
            }
          }
        },
        current_vacancy_stage: {
          include: {
            vacancy_stage_group: { only: %i[id label color value] }
          },
          only: %i[id name evaluation_of_candidate]
        },
        current_candidate_rating: {
          only: %i[id rating_type value],
          include: {
            commenter: {
              only: %i[id photo],
              methods: :full_name
            }
          }
        }
      }
    }
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= [current_vacancy_stage: [:vacancy_stage_group], candidate: [resume: %i[last_work_experience preferred_contact resume_contacts additional_contacts]], current_candidate_rating: [:commenter]]
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [vacancy: :vacancy_stages, candidate: [resume: %i[preferred_contact last_work_experience]], current_vacancy_stage: :vacancy_stage_group, current_candidate_rating: :commenter]
  end

  def search
    result = CandidateVacancy.search(params[:q], params[:vacancy_id])
    count = result.results.total
    if params[:vacancy_stage_id]
      result = CandidateVacancy.where(id: result.page(1).per(count).results.map(&:id)).includes(chain_collection_inclusion).where(current_vacancy_stage_id: params[:vacancy_stage_id]).joins('LEFT OUTER JOIN candidate_ratings ON candidate_ratings.id = (SELECT candidate_ratings.id FROM candidate_ratings WHERE candidate_vacancies.id = candidate_ratings.candidate_vacancy_id AND candidate_vacancies.current_vacancy_stage_id = candidate_ratings.vacancy_stage_id ORDER BY candidate_ratings.created_at DESC LIMIT 1)').reorder('CASE WHEN candidate_ratings.value = 1 THEN 1 WHEN candidate_ratings.value = 0 THEN -1 ELSE 0 END DESC, candidate_vacancies.created_at DESC')
    else
      result = result.page(1).per(count).records.all.includes(chain_collection_inclusion)
    end
    @count = result.count
    result.page(page).per(per_page)
  end

  def set_collection
    @collection ||= params[:q].present? ? search : association_chain
    instance_variable_set("@#{collection_name}", @collection)
  end

  def set_resource
    @resource_instance ||= resource_collection.includes(chain_resource_inclusion).where(vacancy_id: params[:vacancy_id], candidate_id: params[:id]).first
    raise ActiveRecord::RecordNotFound, params[:path] unless @resource_instance.present?
  end

end
