module Accounts
  module Search
    extend ActiveSupport::Concern

    included do
      settings index: {
        number_of_shards: 1,
        analysis: {
          analyzer: {
            trigram: {
              tokenizer: 'trigram',
              filter: [:lowercase]
            }
          },
          tokenizer: {
            trigram: {
              type: 'edge_ngram',
              min_gram: 2,
              max_gram: 20,
              token_chars: %w[letter digit]
            }
          }
        }
      } do
        mapping do
          indexes 'name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'surname', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
            indexes :not_analyzed, type: 'string', index: 'not_analyzed'
          end
          indexes 'middlename', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'position_name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'city', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_work_experiences.position', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_work_experiences.experience_description', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_educations.education_level_name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_educations.school_name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_educations.faculty_name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_educations.speciality', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_educations.language_list.name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_certificates.name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_certificates.company_name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.resume_qualifications.company_name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'resumes.language_list.name', type: 'text', analyzer: 'russian' do
            indexes :trigram, analyzer: 'trigram'
          end
          indexes 'all_legal_unit_employees', type: 'nested' do
            indexes 'position_name', type: 'text', analyzer: 'russian' do
              indexes :trigram, analyzer: 'trigram'
            end
            indexes :legal_unit_id
            indexes :block
            indexes :practice_chain
            indexes :position_name
            indexes :office_id
            indexes :wage, type: :double
            indexes :wage_rate
            indexes :contract_type_id
            indexes :contract_ends_at, type: :date
            indexes :default
            indexes :structure_unit
          end
        end
      end

      def self.search(query, params, hr = false)
        reserved_symbols = %w(+ - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \\ /)
        search_query = query || ''
        # escaping reserved symbols
        reserved_symbols.each do |s|
          search_query.gsub!(s, "\\#{s}")
        end
        search_array = []
        unless search_query.blank?
          search_array.push(
            bool: {
              should: [
                {
                  multi_match: {
                    query: search_query,
                    type: 'cross_fields',
                    fields: hr ? hr_search_fields : search_fields,
                    boost: 4
                  }
                },
                {
                  multi_match: {
                    query: search_query,
                    type: 'cross_fields',
                    analyzer: 'trigram',
                    fields: (hr ? trigram_hr_search_fields : trigram_search_fields),
                    minimum_should_match: '100%'
                  }
                }
              ]
            }
          )
        end
        unless params.blank?
          search_array += (hr ? hr_filter_array(params) : filter_array(params)).compact
        end
        __elasticsearch__.search(
          query: {
            bool: {
              must: search_array
            }
          },
          size: 10000
        )
      end

      def self.hr_search_fields
        @@hr_search_fields ||= %w[
          surname name middlename
          all_legal_unit_employees.position_name
          city
          resumes.resume_work_experiences.position
          resumes.resume_work_experiences.experience_description
          resumes.resume_educations.education_level_name
          resumes.resume_educations.school_name
          resumes.resume_educations.faculty_name
          resumes.resume_educations.speciality
          resumes.resume_certificates.name
          resumes.resume_certificates.company_name
          resumes.resume_qualifications.company_name
          resumes.language_list.name
        ]
      end

      def self.trigram_hr_search_fields
        @@trigram_hr_search_fields ||= %w[
          surname.trigram^30 name.trigram^30 middlename.trigram^30
          all_legal_unit_employees.position_name.trigram^20
          city.trigram^10
          resumes.resume_work_experiences.position.trigram
          resumes.resume_work_experiences.experience_description.trigram
          resumes.resume_educations.education_level_name.trigram
          resumes.resume_educations.school_name.trigram
          resumes.resume_educations.faculty_name.trigram
          resumes.resume_educations.speciality.trigram
          resumes.resume_certificates.name.trigram
          resumes.resume_certificates.company_name.trigram
          resumes.resume_qualifications.company_name.trigram
          resumes.language_list.name.trigram
        ]
      end

      def self.trigram_search_fields
        @@trigram_search_fields ||= %w[surname.trigram^30 name.trigram^30 middlename.trigram^30 position_name.trigram^20 city.trigram^10 resumes.resume_work_experiences.position.trigram resumes.resume_work_experiences.experience_description.trigram resumes.resume_educations.education_level_name.trigram resumes.resume_educations.school_name.trigram resumes.resume_educations.faculty_name.trigram resumes.resume_educations.speciality.trigram resumes.language_list.name.trigram]
      end

      def self.search_fields
        @@search_fields ||= %w[
          surname name middlename position_name city
          resumes.resume_work_experiences.position
          resumes.resume_work_experiences.experience_description
          resumes.resume_educations.education_level_name
          resumes.resume_educations.school_name
          resumes.resume_educations.faculty_name
          resumes.resume_educations.speciality
          resumes.language_list.name
        ]
      end

      def self.filter_array(params = {})
        params.map do |k, v|
          case k
          when 'block'
            {
              bool: {
                should: v.split(',')&.map { |x| { match_phrase: { 'default_legal_unit_employee.block' => x } } }
              }
            }
          when 'practice'
            {
              bool: {
                should: v.split(',')&.map { |x| { match_phrase: { 'default_legal_unit_employee.practice_chain' => x } } }
              }
            }
          when 'city_list'
            {
              bool: {
                should: v.split(',')&.map { |x| { match_phrase: { city: x } } }
              }
            }
          when 'position_list'
            {
              bool: {
                should: v.split(',')&.map { |x| { match_phrase: { position_name: x } } }
              }
            }
          when 'skill_names'
            {
              bool: {
                should: v.split(',')&.map { |x| { match_phrase: { skills_list: x } } }
              }
            }
          when 'starts_with'
            {
              bool: {
                should: {
                  prefix: {
                    'surname.not_analyzed' => v
                  }
                }
              }
            }
          end
        end
      end

      def self.hr_filter_array(params = {})
        array = []
        array << hr_lue_filters(params)
        if params[:skill_names]
          array <<
            {
              bool: {
                should: params[:skill_names].split(',')&.map { |x| { match_phrase: { skills_list: x } } }
              }
            }
        end
        if params[:starts_with]
          array <<
            {
              bool: {
                should: {
                  prefix: {
                    'surname.not_analyzed' => params[:starts_with]
                  }
                }
              }
            }
        end
        array
      end

      def self.hr_lue_filters(params = {})
        lue_params_array = []
        lue_params_array << hr_contract_ends_params(params)
        lue_params_array << hr_wage_params(params)
        params.each do |k, v|
          lue_params_array << case k
                              when 'legal_unit_ids'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { term: { 'all_legal_unit_employees.legal_unit_id' => x } } }
                                  }
                                }
                              when 'block'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { match_phrase: { 'all_legal_unit_employees.block' => x } } }
                                  }
                                }
                              when 'practice'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { match_phrase: { 'all_legal_unit_employees.practice_chain' => x } } }
                                  }
                                }
                              when 'office_ids'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { term: { 'all_legal_unit_employees.office_id' => x } } }
                                  }
                                }
                              when 'position_list'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { match_phrase: { 'all_legal_unit_employees.position_name' => x } } }
                                  }
                                }
                              when 'structure_units'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { match_phrase: { 'all_legal_unit_employees.structure_unit' => x } } }
                                  }
                                }
                              when 'contract_type_ids'
                                {
                                  bool: {
                                    should: v.split(',')&.map { |x| { match_phrase: { 'all_legal_unit_employees.contract_type_id' => x } } }
                                  }
                                }
                              when 'wage_rate'
                                {
                                  bool: {
                                    should: { term: { 'all_legal_unit_employees.wage_rate' => v } }
                                  }
                                }
                              when 'is_default_legal_unit'
                                {
                                  bool: {
                                    should: { term: { 'all_legal_unit_employees.default' => v } }
                                  }
                                }
                              when 'state'
                                {
                                  bool: {
                                    should: { match_phrase: { 'all_legal_unit_employees.state' => v } }
                                  }
                                }
                              when 'show_only'
                                hr_show_only(v)
                              end
        end
        {
          bool: {
            must: {
              nested: {
                path: 'all_legal_unit_employees',
                score_mode: 'avg',
                query: {
                  bool: {
                    must: lue_params_array.compact
                  }
                }
              }
            }
          }
        }
      end

      def self.hr_wage_params(params)
        return if params.slice(:wage_from, :wage_to).blank?
        {
          range: {
            'all_legal_unit_employees.wage' => {
              gte: params[:wage_from],
              lte: params[:wage_to]
            }.compact
          }
        }
      end

      def self.hr_show_only(state)
        case state
        when 'fired'
          {
            bool: {
              should: {
                match_phrase: {
                  'all_legal_unit_employees.state_name' => 'Уволен'
                }
              }
            }
          }
        when 'not_fired'
          {
            bool: {
              must_not: {
                match_phrase: {
                  'all_legal_unit_employees.state_name' => 'Уволен'
                }
              }
            }
          }
        end
      end

      def self.hr_contract_ends_params(params)
        return if params.slice(:contract_ends_from, :contract_ends_to).blank?
        {
          range: {
            'all_legal_unit_employees.contract_ends_at' => {
              gte: params[:contract_ends_from],
              lte: params[:contract_ends_to]
            }.compact
          }
        }
      end
    end

    def as_indexed_json(options = {})
      as_json(
        only: %i[name surname middlename id city],
        methods: %i[position_name email_address phone full_name skills_list],
        include: {
          resumes: {
            only: [],
            include: {
              resume_work_experiences: {
                only: %i[position experience_description]
              },
              resume_educations: {
                only: %i[school_name faculty_name speciality],
                methods: :education_level_name
              },
              resume_certificates: {
                only: %i[name company_name]
              },
              resume_qualifications: {
                only: :company_name
              }
            },
            methods: :language_list
          },
          default_legal_unit_employee: {
            only: %i[position_name],
            methods: %i[block practice_chain]
          },
          all_legal_unit_employees: {
            only: %i[position_name legal_unit_id office_id wage wage_rate contract_type_id contract_ends_at default structure_unit],
            methods: %i[block practice_chain state_name]
          }
        }
      )
    end
  end
end