class ResumeDocuments::ResumeCreator
  include ActionView::Helpers

  def initialize(options = {})
    @document = Docx::Document.open("#{Rails.root}/public/resume_template.docx")
    @resource = options[:resource]
  end

  def build_resume
    @document.bookmarks['MainInfo'].insert_multiple_lines([@resource.last_name, @resource.first_name, @resource.middle_name, @resource.resume&.city, @resource.resume&.resume_source&.name, vacancies].reject(&:blank?))
    @document.bookmarks['ContactInfo'].insert_multiple_lines(resume_contacts.reject(&:blank?))
    @document.bookmarks['GeneralInfo'].insert_multiple_lines([@resource.resume&.birthdate.present? ? I18n.l(@resource.resume&.birthdate) : '',
                                                              @resource.resume&.sex&.present? ? I18n.t("activerecord.enum.sex.#{@resource.resume&.sex}") : '',
                                                              skills,
                                                              ActionView::Base.full_sanitizer.sanitize(@resource.resume&.skills_description),
                                                              language_skills].reject(&:blank?))
    @document.bookmarks['WorkExperiences'].insert_multiple_lines(work_experiences.reject(&:blank?))
    @document.bookmarks['Education'].insert_multiple_lines(education.reject(&:blank?))
    @document.bookmarks['Certificates'].insert_multiple_lines(certificates.reject(&:blank?))
    @document.bookmarks['Courses'].insert_multiple_lines(courses.reject(&:blank?))
    @document.bookmarks['Expectations'].insert_multiple_lines([@resource.resume&.desired_position,
                                                               professional_area,
                                                               professional_specialization,
                                                               formatting_salary_level,
                                                               work_experience,
                                                               schedule,
                                                               employment_type,
                                                               ActionView::Base.full_sanitizer.sanitize(@resource.resume&.comment),
                                                              ].reject(&:blank?))
    @document.bookmarks['Recommendations'].insert_multiple_lines(recommendations.reject(&:blank?))
    path = "#{Rails.root}/tmp/resume_#{SecureRandom.uuid}.docx"
    @document.save(path)
    path
  end

  def vacancies
    @resource.vacancies&.map(&:name)&.join(', ')
  end

  def resume_contacts
    array = []
    @resource.resume&.resume_contacts&.order(:contact_type)&.each do |rc|
      array << "#{rc.value}#{rc.preferred? ? ' - предпочитаемый' : ''}"
    end
    array
  end

  def language_skills
    value = ''
    @resource.resume&.language_skills&.each_with_index do |ls, index|
      value += ', ' if index > 0
      value += "#{ls.language&.name} - #{ls.language_level&.name}"
    end
    value
  end

  def skills
    @resource.resume&.skills&.map(&:name)&.join(', ')
  end

  def work_experiences
    array = []
    @resource.resume&.resume_work_experiences&.each_with_index do |exp, index|
      array << "-------------------" if index > 0
      array += [exp.position, exp.company_name, exp.region, exp.website, distance_of_time_in_words(exp.start_date, exp.end_date || Date.current, only: [:years, :months]), ActionView::Base.full_sanitizer.sanitize(exp.experience_description)]
    end
    array
  end

  def education
    array = []
    @resource.resume&.resume_educations&.each_with_index do |ed, index|
      array << "-------------------" if index > 0
      array += [ed.education_level&.name, ed.school_name, ed.faculty_name, ed.speciality, ed.end_year]
    end
    array
  end

  def certificates
    array = []
    @resource.resume&.resume_certificates&.each_with_index do |cert, index|
      array << "-------------------" if index > 0
      array += [cert.name, cert.company_name, cert.end_date]
    end
    array
  end

  def courses
    array = []
    @resource.resume&.resume_qualifications&.each_with_index do |qual, index|
      array << "-------------------" if index > 0
      array += [qual.name, qual.company_name, qual.speciality, qual.end_year]
    end
    array
  end

  def recommendations
    array = []
    @resource.resume&.resume_recommendations&.each_with_index do |rec, index|
      array << "-------------------" if index > 0
      array += [rec.recommender_name, rec.company_and_position, rec.phone, rec.email]
    end
    array
  end

  def employment_type
    @resource.resume&.employment_type&.map {|x| I18n.t("expectations.type_of_employment.#{x}")}&.join(', ')
  end

  def professional_specialization
    @resource.resume&.professional_specializations&.map(&:name)&.join('/')
  end

  def formatting_salary_level
    "#{@resource.resume&.salary_level&.to_i} рублей"
  end

  def professional_area
    @resource.resume&.professional_specializations&.map(&:professional_area)&.uniq&.map(&:name)&.join(', ')
  end

  def work_experience
    @resource.resume&.experience&.map{|x| I18n.t("expectations.experience.#{x}")}&.join(', ')
  end

  def schedule
    @resource.resume&.working_schedule&.map{|x| I18n.t("expectations.schedule.#{x}")}&.join(', ')
  end
end