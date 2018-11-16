# Create a resume document
class ResumeDocuments::ResumeBuilder < ResumeDocuments::BaseBuilder
  include ActionView::Helpers
  private

  def attributes
    {
        '$first_name$' => @resource.first_name,
        '$last_name$' => @resource.last_name,
        '$middle_name$' => @resource.middle_name,
        '$position$' => @resource.resume&.position,
        '$city$' => @resource.resume&.city,
        '$resume_source$' => @resource.resume&.resume_source&.name,
        '$vacancies$' => vacancies,
        '$resume_contacts$' => resume_contacts,
        '$birthdate$' => @resource.resume&.birthdate.present? ? I18n.l(@resource.resume&.birthdate) : '',
        '$sex$' => I18n.t("activerecord.enum.sex.#{@resource.resume&.sex}"),
        '$skills$' => skills,
        '$skills_description$' => ActionView::Base.full_sanitizer.sanitize(@resource.resume&.skills_description),
        '$language_skills$' => language_skills,
        '$work_experiences$' => work_experiences,
        '$education$' => education,
        '$certificates$' => certificates,
        '$courses$' => courses,
        '$professional_area$' => professional_area,
        '$professional_specialization$' => professional_specialization,
        '$salary$' => formatting_salary_level,
        '$work_experience$' => work_experience,
        '$schedule$' => schedule,
        '$employment_type$' => employment_type,
        '$comment$' => @resource.resume&.comment,
        '$recommendations$' => recommendations
    }
  end

  def professional_area
    @resource.resume&.professional_specializations&.map(&:professional_area)&.uniq&.map(&:name)&.join(', ')
  end

  def line_break
    ""
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

  def vacancies
    @resource.vacancies&.map(&:name)&.join(', ')
  end

  def resume_contacts
    value = ''
    @resource.resume&.resume_contacts&.order(:contact_type)&.each_with_index do |rc, index|
      value += line_break if index > 0
      value += rc.value
      value += '- предпочитаемый' if rc.preferred?
    end
    value
  end

  def skills
    @resource.resume&.skills&.map(&:name)&.join(', ')
  end

  def language_skills
    value = ''
    @resource.resume&.language_skills&.each_with_index do |ls, index|
      value += ', ' if index > 0
      value += "#{ls.language&.name} - #{ls.language_level&.name}"
    end
    value
  end

  def work_experiences
    value = ''
    @resource.resume&.resume_work_experiences&.each_with_index do |exp, index|
      value += "#{line_break}-------------------#{line_break}" if index > 0
      value += "#{exp.position}#{line_break}#{exp.company_name}#{line_break}#{exp.region}#{line_break}#{exp.website}#{line_break}#{distance_of_time_in_words(exp.start_date, exp.end_date || Date.current, only: [:years, :months])}#{line_break}#{exp.experience_description}"
    end
    value
  end

  def education
    value = ''
    @resource.resume&.resume_educations&.each_with_index do |ed, index|
      value += "#{line_break}-------------------#{line_break}" if index > 0
      value += "#{ed.education_level&.name}#{line_break}#{ed.school_name}#{line_break}#{ed.faculty_name}#{line_break}#{ed.speciality}#{line_break}#{ed.end_year}"
    end
    value
  end

  def certificates
    value = ''
    @resource.resume&.resume_certificates&.each_with_index do |cert, index|
      value += "#{line_break}-------------------#{line_break}" if index > 0
      value += "#{cert.name}#{line_break}#{cert.company_name}#{line_break}#{cert.end_date}"
    end
    value
  end

  def courses
    value = ''
    @resource.resume&.resume_qualifications&.each_with_index do |qual, index|
      value += "#{line_break}-------------------#{line_break}" if index > 0
      value += "#{qual.name}#{line_break}#{qual.company_name}#{line_break}#{qual.speciality}#{line_break}#{qual.end_year}"
    end
    value
  end

  def recommendations
    value = ''
    @resource.resume&.resume_recommendations&.each_with_index do |rec, index|
      value += "#{line_break}-------------------#{line_break}" if index > 0
      value += "#{rec.recommender_name}#{line_break}#{rec.company_and_position}#{line_break}#{rec.phone}#{line_break}#{rec.email}"
    end
    value
  end

  def work_experience
    @resource.resume&.experience&.map{|x| I18n.t("expectations.experience.#{x}")}&.join(', ')
  end

  def schedule
    @resource.resume&.working_schedule&.map{|x| I18n.t("expectations.schedule.#{x}")}&.join(', ')
  end
end
