class Api::V0::Resources::ProfilesController < Api::ResourceController
  include ActionController::ImplicitRender
  before_action :set_collection, only: [:index, :index_hr, :export_hr]
  before_action :paginate, only: [:index, :index_hr]
  before_action :set_resource, only: [:edit, :update, :show_hr, :show, :destroy]

  def index
    render :index, as: :json, layout: false
  end

  def index_hr
    render :index_hr, as: :json, layout: false
  end

  def export_hr
    # res ||= params[:q] ? quick_search : association_chain
    # res = filter(res)
    file = Parsers::XLSX::ProfilesXlsxParser.to_xlsx_in_api_format(@collection)
    send_file file, filename: "Пользователи #{I18n.l(Date.today)}.xlsx"
  end

  HR_FULL_INCLUSION = {methods: [:full_name],
                       include: {
                           profile_phones: {}, profile_emails: {}, profile_messengers: {},
                           default_legal_unit_employee: {
                               methods: [:transfers_history, :departments_chain],
                               include: {legal_unit: {}, state: {}, office: {},  contract_type: {}, position: {
                                   include: {position: {}}, department: {}}}
                           },
                           legal_unit_employees: {
                               methods: [:transfers_history, :departments_chain],
                               include: {legal_unit: {}, state: {}, office: {}, contract_type: {}, position: {
                                   include: {position: {}, department: {}}}
                               }}
                           }
                       }

  FULL_INCLUSION = {methods: [:full_name, :managers_chain, :departments_chain, :subordinates_list, :subordinates_count],
                    include: {office: {},
                              skills: {methods: [:skill_confirmations_count], include: [
                                  skill_confirmations: {include: [profile: {methods: [:full_name, :position_name, :departments_chain]}]}]},
                              profile_phones: {}, profile_emails: {}, profile_messengers: {},
                              resumes:{ methods:[:summary_work_period, :preferred_contact, :last_position], include: {
                                  professional_specializations:{ include: { professional_area: {} }},
                                  resume_certificates: {include: {document:{include: {uploaded_by: {methods:[:full_name]}}}}},
                                  raw_resume_doc:{},
                                  resume_contacts:{},
                                  additional_contacts:{},
                                  resume_work_experiences:{},
                                  resume_recommendations:{}, resume_documents:{include: {uploaded_by: {methods:[:full_name]}}},
                                  skills:{}, resume_source:{}, resume_courses:{include: {document: {include: {uploaded_by: {methods:[:full_name]}}}}}, resume_qualifications:{include: {document:{include: {uploaded_by: {methods:[:full_name]}}}}},
                                  resume_educations:{ include: { education_level:{} }},
                                  language_skills: { include: {language:{}, language_level:{}}}
                              }},
                              user: {include: {roles: {}, communities: {}}}, profile_projects: {include: { project_work_periods:{}, project: {}}},
                              default_legal_unit_employee: {methods: [:transfers_history], include: {legal_unit: {}, state: { methods: :versions_history }, contract_type: {}, position: {
                                  include: {position: {}, department: {include: {manager: {}}}}, office: {}, manager: {}
                              }}},
                              legal_unit_employees: {methods: [:transfers_history], include: {legal_unit: {}, state: { methods: :versions_history }, contract_type: {}, position: {
                                  include: {position: {}, department: {include: {manager: {}}}}, office: {}, manager: {}
                              }}}
                    }}

  def show
    render json: @resource_instance.as_json(FULL_INCLUSION)
  end

  def show_hr
    render json: @resource_instance.as_json(HR_FULL_INCLUSION)
  end

  def me
    @resource_instance = Profile.includes(CHAIN_FULL_INCLUSION).where(user_id: current_user.id).first
    render json: @resource_instance.as_json(FULL_INCLUSION)
  end

  def create
    if @resource_instance.save
      render json: @resource_instance.as_json(FULL_INCLUSION)
    else
      render json: {success: false, errors: @resource_instance.errors.as_json}
    end
  end

  def update
    if @resource_instance.update_attributes(resource_params)
      render json: @resource_instance.as_json(FULL_INCLUSION)
    else
      render json: {success: false, errors: @resource_instance.errors.as_json}
    end
  end

  def fullness
    profile = Profile.find(params[:id])
    render json: profile.get_fullness_json
  end

  def update_password
    @resource_instance = current_user&.profile
    if @resource_instance && @resource_instance.update_with_password(password_params)
      bypass_sign_in @resource_instance.user
      render json: {success: true}
    else
      render json: {success: false, errors: @resource_instance&.errors&.as_json}
    end
  end

  private

  SEARCH_OR_FILTER_PARAMS = %w(
      q legal_unit_ids department_ids department_names block_names practice_names office_ids wage_rate contract_type_ids
      wage_from wage_to contract_ends_from
      contract_ends_to state is_default_legal_unit structure_units starts_with city_list position_list skill_names
    ).freeze

  def set_collection
    @collection ||= (params.keys.map(&:to_s) & SEARCH_OR_FILTER_PARAMS).any? ? search_and_filter : association_chain
    instance_variable_set("@#{ collection_name }", @collection)
  end

  def search_and_filter
    es_results = Profile.search(params[:q], params.to_unsafe_h)
    @total_records_for_index = es_results.results.total
    es_results.page(page).per(per_page).records.all
  end

  def starts_with
    params[:starts_with]
  end

  CHAIN_INDEX_INCLUSION = [
      :preferred_email, :preferred_phone, :profile_phones, :skills,
      :profile_emails, user: [:roles],
      all_legal_unit_employees: [:legal_unit_employee_state, :office, :legal_unit,
                                 legal_unit_employee_position: [:position, :department]]
  ]

  CHAIN_FULL_INCLUSION = [
      profile_projects: [ :project ],
      skills:[:skill_confirmations],
      user: [:roles, :communities],
      default_legal_unit_employee: [:legal_unit, :legal_unit_employee_state, :manager, :office,
                                    legal_unit_employee_position: [:position, department: [:manager]]],
      legal_unit_employees: [:legal_unit, :legal_unit_employee_state, :manager,
                             :office, legal_unit_employee_position: [:position, department: [:manager]]],
      resumes:
          [
              :skills, :additional_contacts, :resume_work_experiences, :resume_recommendations, :resume_documents,
              :resume_source, :resume_educations, :resume_courses, :preferred_contact, :resume_contacts, :additional_contacts,
              :resume_qualifications, language_skills:[:language, :language_level]
          ]
  ]


  def association_chain
    res = resource_collection
    @total_records_for_index = resource_collection.count
    res.reorder([:surname, :name, :middlename]).not_admins.not_blocked
  end

  def paginate
    @collection = @collection.page(page).per(per_page)
  end

  def filter_by_elastic(chain)
    res = chain

    legal_unit_ids = params[:legal_unit_ids].try(:split, ',') || []
    res = res.__elasticsearch__.search(
        query: {
            bool: {
                should: legal_unit_ids.map {|x| {term: {'all_legal_unit_employees.legal_unit_id' => x}}}

            },
            minimum_should_match: 1
        }
    ) if legal_unit_ids.any?

  end


  def set_resource
    @resource_instance ||= resource_collection.where(id: params[:id]).includes(CHAIN_FULL_INCLUSION).first
    raise ActiveRecord::RecordNotFound.new(params[:path]) unless @resource_instance.present?
  end


  def permitted_attributes
    [:surname, :name, :middlename, :email, :sex, :city, :photo,
     :birthday, :skype, :kids, :marital_status, social_urls: [],
     skills_attributes: [:id, :name, :project_id, :_destroy],
     default_legal_unit_employee_attributes: [:id, :legal_unit_id,
                                              :office_id, :manager_id, :email_work, :email_corporate, :phone_work, :phone_corporate,
                                              legal_unit_employee_position_attributes: [:id, :department_code, :position_code],
                                              legal_unit_employee_state_attributes: [:id, :state]
     ],
     resumes_attributes:
         [
             :id, :user_id, :profile_id, :first_name, :middle_name, :resume_file, :remote_resume_file_url, :manual,
             :last_name, :position, :city, :resume_text,
             :birthdate, :photo, :remote_photo_url, :sex,
             :martial_condition, :have_children, :skills_description, :specialization,
             :desired_position, :salary_level, :comment, :documents, :candidate_id,
             :user_id, :vacancy_id, :resume_source_id, :raw_resume_doc_id, professional_specialization_ids:[],
             skill_list:[], experience:[], employment_type:[],
             working_schedule:[], additional_contacts_attributes: [:id, :type, :link, :_destroy],
             resume_contacts_attributes: [:id, :contact_type, :value, :preferred, :_destroy],
             language_skills_attributes: [:id, :language_id, :language_level_id, :_destroy, language_attributes:[:name]],
             resume_documents_attributes: [:id, :file, :name, :_destroy],
             resume_certificates_attributes:[:id, :name, :company_name, :file, :start_date, :end_date, :_destroy, document_attributes: [:id, :file, :name, :_destroy]],
             resume_work_experiences_attributes: [:id, :position, :company_name,
                                                  :region, :website, :start_date,
                                                  :end_date, :experience_description, :_destroy],
             resume_recommendations_attributes: [:id, :recommender_name, :company_and_position,
                                                 :phone, :email, :_destroy],
             resume_educations_attributes: [:id, :education_level_id, :school_name,
                                            :faculty_name, :speciality, :end_year, :_destroy],
             resume_qualifications_attributes: [:id, :name, :company_name,
                                                :speciality, :end_year, :file, :_destroy, document_attributes: [:id, :file, :name, :_destroy]],
             resume_courses_attributes: [:id, :name, :company_name, :end_year, :file, :_destroy, document_attributes: [:id, :file, :name, :_destroy]],
         ],
     profile_phones_attributes: [:id, :kind, :number, :preferable, :whatsapp, :telegram, :viber, :profile_id, :_destroy],
     profile_emails_attributes: [:id, :kind, :email, :preferable, :profile_id, :_destroy],
     profile_messengers_attributes: [:id, :name, :profile_id, :_destroy, phones: []]
    ]
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
