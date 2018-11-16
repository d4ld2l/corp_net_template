class Api::V0::Resources::CandidatesController < Api::ResourceController
  include Candidate::Parsing

  def index
    if select_candidates
      inclusion = params[:response_format]=='index' ? json_collection_inclusion : json_select_inclusion
      render json: @collection.as_json(inclusion)
    else
      render json: { data: @collection.as_json(json_collection_inclusion), count: @count }
    end
  end

  def dictionary
    render json: Candidate.all.includes(:resume).select(:id, :last_name, :first_name, :middle_name, 'resumes.photo').order(:created_at).references(:resumes).as_json(
      only: %i[id],
      methods: :full_name,
      include: {
        resume: {
          only: :photo
        }
      }
    )
  end

  private

  def association_chain
    if select_candidates
      result = resource_collection.includes(chain_select_inclusion).where(id: select_candidates)
    else
      result = resource_collection.includes(chain_collection_inclusion)
      if vacancy_stage_group_scope
        result = result.joins(candidate_vacancies: :current_vacancy_stage).where('vacancy_stages.vacancy_stage_group_id = ?', vacancy_stage_group_scope)
      end
      result = if unassigned_scope
                 result.unassigned
               else
                 result.distinct
               end
    end
    result.reorder(created_at: :desc).page(page).per(per_page)
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      include: {
        candidate_vacancies_in_use: {
          include: {
            current_vacancy_stage: {
              include: {
                vacancy_stage_group: { only: %i[id label color value] }
              },
              only: %i[id name]
            },
            vacancy: {
              only: %i[id name]
            }
          },
          only: :id
        },
        resume: {
          include: {
            preferred_contact: {
              only: %i[id contact_type value]
            }
          },
          only: %i[city desired_position id photo]
        }
      },
      methods: %i[last_action full_name]
    }
  end

  def json_select_inclusion
    @json_select_inclusion ||= if params[:light] == 'true'
                                 json_collection_inclusion
                               else
                                 {
                                   methods: :full_name,
                                   include: {
                                     candidate_vacancies: {
                                       include: {
                                         current_vacancy_stage: {
                                           include: {
                                             vacancy_stage_group: { only: %i[id label color value] }
                                           },
                                           only: %i[id name evaluation_of_candidate]
                                         },
                                         vacancy: {
                                           only: %i[id name]
                                         }
                                       }
                                     },
                                     resume: {
                                       methods: %i[summary_work_period preferred_contact last_position],
                                       include: {
                                           education_level: {},
                                         professional_specializations: {
                                           include: {
                                             professional_area: {}
                                           }
                                         },
                                         resume_certificates: {},
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
                                         resume_courses: {},
                                         resume_qualifications: {},
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
                                     }
                                   }
                                 }
                               end
  end

  def chain_select_inclusion
    if params[:light] == 'true'
      chain_collection_inclusion
    else
      [
        candidate_vacancies: [
          current_vacancy_stage: [:vacancy_stage_group],
          vacancy: []
        ],
        resume: [
          :skills, :resume_work_experiences, :resume_recommendations, :resume_documents,
          :resume_source, :resume_educations, :resume_courses, :preferred_contact, :resume_contacts, :additional_contacts,
          :resume_qualifications, language_skills: %i[language language_level]
        ]
      ]
    end
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= if params[:light] == 'true'
                                   {
                                     methods: :full_name,
                                     include: {
                                       candidate_vacancies_active: {
                                         include: {
                                           current_vacancy_stage: {
                                             include: {
                                               vacancy_stage_group: { only: %i[id label color value] }
                                             },
                                             only: %i[id name evaluation_of_candidate]
                                           },
                                           vacancy: {
                                             only: %i[id name]
                                           },
                                           current_candidate_rating: {
                                             only: %i[id rating_type value],
                                             include: {
                                               commenter: {
                                                 only: %i[id photo],
                                                 methods: :name_surname
                                               }
                                             }
                                           }
                                         },
                                         only: :id
                                       },
                                       resume: {
                                         methods: %i[last_position],
                                         only: %i[city desired_position id photo salary_level],
                                         include: {
                                           education_level: {},
                                           preferred_contact: {
                                             only: %i[id contact_type value]
                                           },
                                           resume_contacts: {},
                                           additional_contacts: {},
                                           last_work_experience: {},
                                           raw_resume_doc: { only: [:id, :file] }
                                         }
                                       },
                                       candidate_changes: {
                                         include: {
                                           account: {
                                             only: %i[id photo],
                                             methods: :full_name
                                           },
                                           vacancy: {
                                             only: %i[id name]
                                           },
                                           change_for: {}
                                         }
                                       }
                                     }
                                   }
                                 else
                                   {
                                     include: {
                                       candidate_vacancies: {
                                         methods: :next_vacancy_stage,
                                         include: {
                                           current_vacancy_stage: {
                                             include: {
                                               vacancy_stage_group: { only: %i[id label color value] }
                                             },
                                             only: %i[id name evaluation_of_candidate]
                                           },
                                           vacancy: {
                                             only: %i[id name],
                                             include: {
                                               vacancy_stages: {
                                                 include: {
                                                   vacancy_stage_group: { only: %i[id label color value] }
                                                 },
                                                 methods: [:candidates_count]
                                               }
                                             }
                                           },
                                           current_candidate_rating: {
                                             only: %i[id rating_type value],
                                             include: {
                                               commenter: {
                                                 only: %i[id photo],
                                                 methods: :full_name
                                               }
                                             }
                                           },
                                           comments: {
                                             include: {
                                               account: {
                                                 only: %i[id photo],
                                                 methods: :name_surname
                                               }
                                             }
                                           }
                                         }
                                       },
                                       resume: {
                                         methods: %i[summary_work_period preferred_contact last_position],
                                         include: {
                                           education_level: {},
                                           professional_specializations: {
                                             include: {
                                               professional_area: {}
                                             }
                                           },
                                           resume_certificates: {},
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
                                           resume_courses: {},
                                           resume_qualifications: {},
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
                                       old_resumes: {
                                         methods: %i[summary_work_period preferred_contact last_position],
                                         include: {
                                           education_level: {},
                                           professional_specializations: {
                                             include: {
                                               professional_area: {}
                                             }
                                           },
                                           resume_certificates: {},
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
                                           resume_courses: {},
                                           resume_qualifications: {},
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
                                       candidate_changes: {
                                         include: {
                                           account: {
                                             only: %i[id photo],
                                             methods: :full_name
                                           },
                                           vacancy: {
                                             only: %i[id name]
                                           },
                                           change_for: {}
                                         }
                                       }
                                     },
                                     methods: %i[similar_candidates full_name]
                                   }
                                 end
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= if params[:light] == 'true'
                                    [
                                      candidate_changes: %i[vacancy account],
                                      candidate_vacancies_active: [current_vacancy_stage: [:vacancy_stage_group], vacancy: [], current_candidate_rating: [:commenter]],
                                      resume: %i[raw_resume_doc education_level last_work_experience preferred_contact resume_contacts additional_contacts]
                                    ]
                                  else
                                    [candidate_changes: %i[vacancy account],
                                     candidate_vacancies: [current_vacancy_stage: [:vacancy_stage_group],
                                                           vacancy: [vacancy_stages: [:vacancy_stage_group]],
                                                           comments: [:account],
                                                           current_candidate_rating: [:commenter]],
                                     resume:
                                       [
                                         :skills, :education_level, :resume_work_experiences, :resume_recommendations, :resume_documents, :last_work_experience,
                                         :resume_source, :resume_educations, :resume_courses, :preferred_contact, :resume_contacts, :additional_contacts,
                                         :resume_qualifications, language_skills: %i[language language_level]
                                       ],
                                     old_resumes: [
                                       :skills, :resume_work_experiences, :education_level, :resume_recommendations, :resume_documents, :last_work_experience,
                                       :resume_source, :resume_courses, :preferred_contact, :resume_contacts, :additional_contacts,
                                       :resume_qualifications, language_skills: %i[language language_level], resume_educations: :education_level
                                     ]
                                    ]
                                  end
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [candidate_changes: [],
                                     candidate_vacancies_in_use: [
                                       current_vacancy_stage: [:vacancy_stage_group],
                                       vacancy: []
                                     ],
                                     resume: :preferred_contact]
  end

  def vacancy_stage_group_scope
    @vacancy_stage_group_scope ||= params[:vacancy_stage_group_id]
  end

  def unassigned_scope
    @unassigned_scope ||= params[:unassigned]
  end

  def permitted_attributes
    [
      :first_name, :middle_name, :last_name, :birthdate,
      candidate_vacancies_attributes: %i[id vacancy_id current_vacancy_stage_id _destroy],
      resume_attributes:
        [
          :id, :candidate_id, :resume_file, :remote_resume_file_url, :manual,
          :city, :resume_text,
          :photo, :remote_photo_url, :remove_photo, :sex,
          :martial_condition, :education_level_id, :have_children, :skills_description, :specialization,
          :desired_position, :salary_level, :comment, :documents, :resume_source_id, :raw_resume_doc_id,
          professional_specialization_ids: [],
          skill_list: [], experience: [], employment_type: [],
          working_schedule: [], additional_contacts_attributes: %i[id type link],
          resume_contacts_attributes: %i[id contact_type value preferred _destroy],
          language_skills_attributes: [:id, :_destroy, :language_id, :language_level_id, language_attributes: [:name]],
          resume_documents_attributes: %i[id file name _destroy],
          resume_certificates_attributes: %i[id name company_name start_date file end_date _destroy],
          resume_work_experiences_attributes: %i[id position company_name region website start_date end_date experience_description _destroy],
          resume_recommendations_attributes: %i[id recommender_name company_and_position phone email _destroy],
          resume_educations_attributes: %i[id education_level_id school_name faculty_name speciality end_year _destroy],
          resume_qualifications_attributes: %i[id name company_name speciality end_year file _destroy],
          resume_courses_attributes: %i[id name company_name end_year file _destroy]
        ]
    ]
  end

  def search
    result = Candidate.search(params[:q], current_tenant&.id, params.to_unsafe_h)
    @count = result.results.total
    result.page(page).per(per_page).records.all
  end

  def set_collection
    @collection ||= (params.keys.map(&:to_s) & %w[q sort experience working_schedule employment_type city skills professional_specializations vacancy_stage_groups vacancies education_level language]).any? ? search : association_chain
    instance_variable_set("@#{collection_name}", @collection)
  end

  def set_resource
    super
    CandidateChanges::EagerLoader.preload(@resource_instance.candidate_changes)
  end

  def select_candidates
    return unless params[:select]
    ids = params[:select].split(',').map(&:to_i)
    @select_candidates ||= ids.all? ? ids : nil
  end

  def build_resource
    file = resource_params.dig('resume_attributes')&.delete('remote_resume_file_url')&.tap { |x| x.gsub!(/\A\//, '') }
    super
    @resource_instance.resume.resume_file = File.open(Rails.root.join('public', file)) if file && File.exist?(Rails.root.join('public', file)) && @resource_instance&.resume
  end
end
