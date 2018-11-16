module Candidate::Parsing
  extend ActiveSupport::Concern

  def parse_file
    file = nil
    if params[:file]
      file = params[:file]
      if file.instance_of? String
        file_content_type = file.split(',').first.split(';').first.gsub('data:', '')
        file_format = case file_content_type
                        when 'application/msword'
                          '.doc'
                        when 'application/pdf'
                          '.pdf'
                        else
                          '.docx'
                      end
        tmp = Tempfile.new(["temp_resume", file_format])
        tmp << Base64.decode64(file.split(',').last&.gsub('\\r', "\r")&.gsub('\\n', "\n"))&.force_encoding('UTF-8')
        tmp.close
        file = tmp
      else
        file_content_type = file.content_type
        file = file.tempfile
      end
    else
      render json: {success: false, error: 'Необходимо передать файл в формате .doc, .docx или .pdf'}
    end
    result = {}
    Converters::DocToDocx.convert(file.path) do |converted|
      c_file = File.open(converted) rescue nil
      if (Parsers::HH::BaseResumeParser.check_format(c_file) rescue nil)
        result = Parsers::HH::ResumeDocx.new(path: converted, format: 'docx').parse
      else
        result = Parsers::Common::ResumeParser.parse(file)
      end
    end
    candidate = Candidate.new(first_name: result.fetch(:first_name),
                              middle_name: result.fetch(:middle_name),
                              last_name: result.fetch(:last_name),
                              birthdate: result.fetch(:birthdate),
                              resume_attributes: result)
    candidate.resume&.resume_file = file
    candidate = candidate.as_json(include: {
        candidate_vacancies: {methods: :next_vacancy_stage},
        resume: {methods: [:skill_list, :summary_work_period], include: {
            resume_contacts:{},
            education_level: {},
            additional_contacts: {},
            resume_work_experiences: {},
            resume_recommendations: {},
            resume_certificates: {},
            resume_documents: {},
            resume_source: {}, resume_courses: {}, resume_qualifications: {},
            resume_educations: {include: {education_level: {}}},
            professional_specializations: {include: {professional_area: {}}},
            language_skills: {include: {language: {}, language_level: {}}},
        }},
        candidate_changes: {include: {user: {include: :profile, methods: :full_name}, vacancy: {}, change_for: {}}}
    })
    file.delete
    render json: candidate
  end
end
