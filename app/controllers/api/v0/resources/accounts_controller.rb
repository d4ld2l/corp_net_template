class Api::V0::Resources::AccountsController < Api::ResourceController
  before_action :authenticate_account!, except: %i[generate_new_password_email reset_password]
  before_action -> { params[:hr] = 'true' }, only: :export_hr
  before_action :set_collection, only: %i[index export_hr]
  before_action :set_dictionary_collection, only: [:dictionary]
  before_action :set_resource, only: %i[edit update show destroy]

  def dictionary
    ## TODO: create good filters
    ## DEPRECATED BLOCK BEGIN
    if params[:role_name]
      @collection = @collection.joins(account_roles: :role).where(account_roles: { roles: { name: params[:role_name] } })
    end
    if params[:legal_unit_id]
      @collection = @collection.joins(:all_legal_unit_employees).where('legal_unit_employees.legal_unit_id = ?', params[:legal_unit_id])
    end
    if params[:department_code]
      @collection = @collection.joins(all_legal_unit_employees: :legal_unit_employee_position).where(
        legal_unit_employees: { legal_unit_employee_positions: { department_code: params[:department_code] } }
      )
    end
    if params[:project_id]
      @collection = @collection.joins(:account_projects).where('account_projects.project_id = ?', params[:project_id])
    end
    if params[:permission_name]
      @collection = @collection.joins(account_roles: [role: [role_permissions: :permission]]).where(account_roles: { roles: { role_permissions: { permissions: { name: params[:permission_name] } } } })
    end
    if params[:only_with_legal_unit] == 'true'
      @collection = @collection.only_with_legal_unit
    end
    ## DEPRECATED BLOCK END
    render json: @collection.as_json(only: [:id], methods: %i[photo_url birthday full_name])
  end

  def index
    render json: { data: @collection.as_json(json_collection_inclusion), count: @count }
  end

  def export_hr
    file = Parsers::XLSX::AccountsXlsxParser.to_xlsx_in_api_format(@collection)
    send_file file, filename: "Пользователи #{I18n.l(Date.today)}.xlsx"
  end

  def generate_new_password_email
    @account = Account.find_by(email: params[:email]&.downcase)
    if @account.present?
      @account.send(:set_reset_password_token)
      ResetPasswordMailer.send_email(@account.id).deliver_later
      render json: { success: true, message: 'Письмо с дальнейшими инструкциями было выслано на почту' }
    else
      render json: { success: false, message: 'Пользователя с таким e-mail не существует' }
    end
  end

  def me
    @resource_instance ||= resource_collection.includes(chain_resource_inclusion).find(current_account.id)
    render json: @resource_instance.as_json(json_resource_inclusion)
  end

  def fullness
    account = Account.find(params[:id])
    render json: account.get_fullness_json
  end

  def reset_password
    @account = Account.find_by(reset_password_token: params[:reset_password_token])
    if @account.present?
      if @account.reset_password_period_valid?
        if @account.reset_password(params[:password], params[:password_confirmation])
          @account.tokens.clear
          @account.save!
          ResetPasswordMailer.password_changed_email(@account.id).deliver_later
          render json: { success: true, message: 'Пароль обновлен успешно' }
        else
          render json: { success: false, errors: @account.errors.as_json }
        end
      else
        render json: { success: false, message: 'Истек срок действия ссылки' }
      end
    else
      render json: { success: false, message: 'Истек срок действия ссылки или она уже использовалась для восстановления пароля' }
    end
  end

  def update_password
    @account = current_account
    if @account.update_with_password(password_params)
      bypass_sign_in(@account)
      @account.tokens.delete_if { |k, _| k != request.headers['client'] }
      @account.save!
      ResetPasswordMailer.password_changed_email(@account.id).deliver_later
      render json: { success: true, message: 'Пароль обновлен успешно' }
    else
      render json: { success: false, errors: @account.errors.as_json }
    end
  end

  def get_ticket
    token = Devise.friendly_token(15)
    response.headers['X-WS-TICKET'] = token
    r = Redis.new(url: ENV['REDIS_URL'] + '/0')
    r.set("ws_tickets:#{token}", current_account&.id)
    r.expire("ws_tickets:#{token}", 60)
    r.close
    render json: { success: true }
  end

  private

  def search_and_filter
    es_results = Account.search(params[:q], params.to_unsafe_h, params['hr'] == 'true')
    @count = es_results.records.not_admins.not_blocked.distinct.count
    es_results.per(@count).records.includes(chain_collection_inclusion).not_admins.not_blocked.page(page).per(per_page)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end

  def set_resource
    @resource_instance ||= resource_collection.includes(chain_resource_inclusion).find(params[:id])
    raise ActiveRecord::RecordNotFound, params[:path] unless @resource_instance.present?
  end

  def set_collection
    @collection ||= (params.keys.map(&:to_s) & %w[q wage_to wage_from contract_ends_to contract_ends_from show_only state is_default_legal_unit wage_rate contract_type_ids structure_units office_ids legal_unit_ids block starts_with practice city_list position_list skill_names]).any? ? search_and_filter : association_chain
    instance_variable_set("@#{collection_name}", @collection)
  end

  def set_dictionary_collection
    @collection ||= (params.keys.map(&:to_s) & %w[q]).any? ? search_and_filter : resource_collection.reorder(%i[surname name middlename]).not_admins.not_blocked
    instance_variable_set("@#{collection_name}", @collection)
  end

  def association_chain
    res = resource_collection.includes(chain_collection_inclusion)
    @total_records_for_index = resource_collection.count
    res = res.reorder(%i[surname name middlename]).not_admins.not_blocked
    @count = res.count
    res.page(page).per(per_page)
  end

  def per_page
    action_name == 'export_hr' ? @count || super : super
  end

  def permitted_attributes
    [
      :surname, :name, :middlename, :email, :sex, :city, :photo,
      :password, :password_confirmation,
      :birthday, :skype, :kids, :marital_status,
      social_urls: [],
      account_skills_attributes: [:id, :project_id, :skill_id, :_destroy, skill_attributes: [:name]],
      default_legal_unit_employee_attributes: [
        :id, :legal_unit_id,
        :office_id, :manager_id, :email_work, :email_corporate, :phone_work, :phone_corporate,
        legal_unit_employee_position_attributes: %i[id department_code position_code],
        legal_unit_employee_state_attributes: %i[id state]
      ],
      resumes_attributes: [
        :id, :first_name, :middle_name, :resume_file, :remote_resume_file_url, :manual,
        :last_name, :position, :city, :resume_text,
        :photo, :remote_photo_url, :sex,
        :martial_condition, :have_children, :skills_description, :specialization,
        :desired_position, :salary_level, :comment, :documents, :candidate_id,
        :user_id, :vacancy_id, :resume_source_id, :raw_resume_doc_id,
        professional_specialization_ids: [],
        skill_list: [], experience: [], employment_type: [],
        working_schedule: [], additional_contacts_attributes: %i[id type link _destroy],
        resume_contacts_attributes: %i[id contact_type value preferred _destroy],
        language_skills_attributes: [:id, :language_id, :language_level_id, :_destroy, language_attributes: [:name]],
        resume_documents_attributes: %i[id file name _destroy],
        resume_certificates_attributes: [:id, :name, :company_name, :file, :start_date, :end_date, :_destroy, document_attributes: %i[id file name _destroy]],
        resume_work_experiences_attributes: %i[id position company_name region website start_date end_date experience_description _destroy],
        resume_recommendations_attributes: %i[id recommender_name company_and_position phone email _destroy],
        resume_educations_attributes: %i[id education_level_id school_name faculty_name speciality end_year _destroy],
        resume_qualifications_attributes: [:id, :name, :company_name, :speciality, :end_year, :file, :_destroy, document_attributes: %i[id file name _destroy]],
        resume_courses_attributes: [:id, :name, :company_name, :end_year, :file, :_destroy, document_attributes: %i[id file name _destroy]]
      ],
      account_phones_attributes: %i[id kind number preferable whatsapp telegram viber _destroy],
      account_emails_attributes: %i[id kind email preferable _destroy],
      account_messengers_attributes: [:id, :name, :_destroy, phones: []]
    ]
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= if params[:hr] == 'true'
                                     {
                                       only: %i[id photo birthday],
                                       methods: :full_name,
                                       include: {
                                         default_legal_unit_employee: {
                                           methods: %i[department_name legal_unit_name],
                                           only: %i[id wage_rate structure_unit]
                                         },
                                         legal_unit_employees: {
                                           methods: %i[department_name legal_unit_name],
                                           only: %i[id wage_rate structure_unit]
                                         }
                                       }
                                     }
                                   else
                                     {
                                       only: %i[id photo skype city],
                                       methods: %i[full_name phone email_address],
                                       include: {
                                         default_legal_unit_employee: {
                                           methods: %i[department_name position_name],
                                           only: %i[id]
                                         }
                                       }
                                     }
                                   end
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= if params[:hr] == 'true'
                                   {
                                     only: %i[id photo birthday skype],
                                     methods: %i[full_name phone email_address],
                                     include: {
                                       all_legal_unit_employees: {
                                         methods: %i[department_name
                                                     legal_unit_name
                                                     departments_chain
                                                     position_name
                                                     office_name
                                                     contract_type_name
                                                     state_name
                                                     transfers_history]
                                       }
                                     }
                                   }
                                 else
                                   {
                                     methods: %i[phone email_address full_name departments_chain managers_chain subordinates_list subordinates_count],
                                     include: {
                                       all_legal_unit_employees: {
                                         include: {
                                           state: {
                                             methods: :versions_history
                                           },
                                           legal_unit: {},
                                           contract_type: {},
                                           position: {
                                             include: {
                                               position: {},
                                               department: {
                                                 include: {
                                                   manager: {}
                                                 }
                                               }
                                             },
                                             office: {},
                                             manager: {}
                                           }
                                         },
                                         methods: %i[transfers_history]
                                       },
                                       account_skills: {
                                         include: {
                                           skill: {
                                             only: %i[id name]
                                           },
                                           skill_confirmations: {
                                             only: %i[id],
                                             include: {
                                               account: {
                                                 only: %i[id photo],
                                                 methods: %i[position_name full_name]
                                               }
                                             }
                                           }
                                         }
                                       },
                                       account_phones: {},
                                       account_emails: {},
                                       account_messengers: {},
                                       resumes: {
                                         methods: %i[
                                           summary_work_period
                                           preferred_contact
                                           last_position
                                         ],
                                         include: {
                                           professional_specializations: {
                                             include: {
                                               professional_area: {}
                                             }
                                           },
                                           resume_certificates: {
                                             include: {
                                               document: {
                                                 include: {
                                                   uploaded_by: { methods: [:full_name] }
                                                 }
                                               }
                                             }
                                           },
                                           raw_resume_doc: {},
                                           resume_contacts: {},
                                           additional_contacts: {},
                                           resume_work_experiences: {},
                                           resume_recommendations: {},
                                           resume_documents: {
                                             include: {
                                               uploaded_by: {
                                                 methods: [:full_name]
                                               }
                                             }
                                           },
                                           skills: {},
                                           resume_source: {},
                                           resume_courses: {
                                             include: {
                                               document: {
                                                 include: {
                                                   uploaded_by: {
                                                     methods: [:full_name]
                                                   }
                                                 }
                                               }
                                             }
                                           },
                                           resume_qualifications: {
                                             include: {
                                               document: {
                                                 include: {
                                                   uploaded_by: {
                                                     methods: [:full_name]
                                                   }
                                                 }
                                               }
                                             }
                                           },
                                           resume_educations: {
                                             include: {
                                               education_level: {}
                                             }
                                           },
                                           language_skills: {
                                             include: {
                                               language: {},
                                               language_level: {}
                                             }
                                           }
                                         }
                                       },
                                       roles: {},
                                       communities: {},
                                       account_projects: {
                                         include: {
                                           project: {
                                             only: %i[id title]
                                           },
                                           project_work_periods: {}
                                         }
                                       }
                                     }
                                   }
                                 end
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= if params[:hr] == 'true'
                                      [
                                        default_legal_unit_employee: [position: :department, legal_unit: []],
                                        legal_unit_employees: [position: :department, legal_unit: []], roles: []
                                      ]
                                    else
                                      [
                                        default_legal_unit_employee: [position: %i[department position]],
                                        account_phones: [], account_emails: [], preferred_email: [], preferred_phone: [], roles: []
                                      ]
                                    end
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= if params[:hr] == 'true'
                                    [
                                      all_legal_unit_employees: [position: %i[position department], legal_unit: [], office: [], contract_type: [], state: []],
                                      account_phones: [], account_emails: [], preferred_email: [], preferred_phone: [], roles: []
                                    ]
                                  else
                                    [
                                      all_legal_unit_employees: [position: [:position, department: :manager], legal_unit: [], office: [], contract_type: [], state: [], manager: []],
                                      account_phones: [],
                                      account_emails: [],
                                      preferred_email: [],
                                      preferred_phone: [],
                                      roles: [],
                                      account_skills: [:skill, skill_confirmations: :account],
                                      resumes: [
                                        :skills, :resume_work_experiences, :resume_recommendations, :resume_documents, :last_work_experience,
                                        :resume_source, :resume_educations, :resume_courses, :preferred_contact, :resume_contacts, :additional_contacts,
                                        :resume_qualifications, language_skills: %i[language language_level]
                                      ]
                                    ]
                                  end
  end
end
