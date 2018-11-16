module Accounts
  module Fullness
    extend ActiveSupport::Concern

    included do
      def self.get_fullness_json(id)
        acc = Account.includes(account_projects: [:project_work_periods], account_messengers: [], skills: [], account_phones: [], account_emails: [], preferred_phone: [], preferred_email: []).find(id)
        resumes_filled = projects_filled = false
        lue = acc.default_legal_unit_employee

        # получение заполненности мессенджеров, нужно ниже
        c_messengers = false
        acc.account_messengers.each do |am|
          c_messengers = am.phones.present? && am.name.present?
          break if c_messengers
        end

        # вкладка "контакты"

        contacts_filled = (acc.phone.present? || lue&.phone_corporate.present? || lue&.phone_work.present?) &&
                          # (email.present? || lue.email_corporate.present? || lue.email_work.present?) &&
                          acc.email.present? &&
                          (c_messengers || acc.skype.present?) &&
                          acc.social_urls.present?

        # вкладка "навыки"

        skills_filled = acc.skills.present?

        acc.resumes.each do |resume|
          # общая вкладка
          r_general = false
          resume.resume_work_experiences.each do |rwe|
            r_general = rwe.position.present? && rwe.company_name.present? && rwe.region.present? &&
                        rwe.start_date.present? && rwe.experience_description.present? # && rwe.website.present?
            break if r_general
          end

          # образование
          r_educations = false
          resume.resume_educations.each do |re|
            r_educations = re.education_level_id.present? && re.school_name.present?
            break if r_educations
          end

          # языки
          r_langs = resume.language_skills.present?

          # Стало необязательным в связи с уточнением постановки:
          #
          # # сертификаты
          # r_certs = false
          # resume.resume_certificates.each do |rcert|
          #   r_certs = rcert.start_date.present? && rcert.company_name.present? && rcert.name.present?
          #   break if r_certs
          # end
          #
          # # курсы
          # r_courses = false
          # resume.resume_courses.each do |rcrse|
          #   r_courses = rcrse.company_name.present? && rcrse.name.present? && rcrse.end_year.present?
          #   break if r_courses
          # end

          # подытожим...                                          V    НЕОБЯЗАТЕЛЬНОЕ   V
          resumes_filled = r_general && r_educations && r_langs # && r_certs && r_courses
          break if resumes_filled
        end

        acc.account_projects.each do |ap|
          ap.project_work_periods.each do |pwp|
            projects_filled = pwp.begin_date.present? && pwp.duties.present? && pwp.role.present?
            break if projects_filled
          end
        end

        { id: id, contacts_filled: contacts_filled, skills_filled: skills_filled,
          resumes_filled: resumes_filled, projects_filled: projects_filled }
      end

      def get_fullness_json
        Account.get_fullness_json(id)
      end
    end
  end
end
