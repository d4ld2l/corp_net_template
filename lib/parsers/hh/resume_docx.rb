require_relative '../base_parser'

module Parsers
  module HH
    class ResumeDocx < Parsers::HH::BaseResumeParser
      def parse
        docx = open_file
        index = docx.paragraphs[0].text.present? ? 1 : 0
        #index += docx.paragraphs[1].text.match?(/женщина|мужчина|года|лет|родился|родилась/i) ? 1 : 0
        result = HashWithIndifferentAccess.new(
                                      parsed: true,
                                      manual: false,
                                      first_name: exception_handler { full_name(docx, 1 - index).split(' ')[1] },
                                      middle_name: exception_handler { full_name(docx, 1 - index).split(' ')[2] },
                                      last_name: exception_handler { full_name(docx, 1 - index).split(' ')[0] },
                                      sex: exception_handler { gender { Nokogiri::HTML(docx.paragraphs[2- index].to_html).content } },
                                      city: exception_handler { city(docx) },
                                      birthdate: exception_handler { DateTime.parse(convert_month( birthday { Nokogiri::HTML(docx.paragraphs[2- index].to_html).content }))},
                                      resume_contacts: contacts(docx, index),
                                      #phone: exception_handler { phone { Nokogiri::HTML(docx.paragraphs[4 - index].to_html).content }}, # Deprecate
                                      #email: exception_handler { email(docx, 5 - index) }, # Deprecate
                                      #skype: exception_handler { skype(docx, 6 - index) }, # Deprecate
                                      photo: exception_handler { photo },
                                      additional_contacts_attributes: exception_handler([]) { additional_contacts(docx) },
                                      #preferred_contact_type: exception_handler { preferred_contact_type(docx, index) },
                                      desired_position: exception_handler { desired_position(docx) },
                                      salary_level: exception_handler { salary_level(docx) },
                                      professional_specializations: exception_handler([]) { professional_specializations(docx) },
                                      specialization: exception_handler { specialization(docx) },
                                      employment_type: exception_handler { employment_type(parse_checkbox(docx, /Занятость/)) },
                                      working_schedule: exception_handler([]) { working_schedule(parse_checkbox(docx, /График работы/)) },
                                      resume_work_experiences_attributes: exception_handler([]) { experience(docx) },
                                      resume_educations_attributes: exception_handler([]) { education(docx) },
                                      resume_certificates_attributes: exception_handler([]) { certificates(docx) },
                                      resume_courses_attributes: exception_handler([]) { courses(docx) },
                                      resume_recommendations_attributes: exception_handler([]) { recommendations(docx) },
                                      education_level_id: exception_handler { education_level(docx)&.id },
                                      language_skills_attributes: exception_handler([]) { language(docx) },
                                      skill_list: exception_handler([]) { skills(docx) },
                                      skills_description:  skills_description(docx) ,
                                      resume_source_id: exception_handler { ResumeSource.find_or_create_by(name:'HeadHunter').id }
        )
        result
      end

      def contacts(docx, index)
        start_i = 3
        end_i = nil

        finished_data = []
        parse_data(docx, { start: /родил/, end: /Желаемая должность и зарплата/}) do |start_index, end_index|
          end_i = end_index&.first
        end

        (start_i..end_i-1).each do |i|
          line = docx.paragraphs[i&.to_i].to_s
          if line&.present? && !line.match(/ICQ|Free-lance|Facebook|LinkedIn/)
            if line =~ /[\+ \(\)\d ]{8,16}/
              val = line.match /[\+ \(\)\d ]{8,16}/
              pref = line.match(/предпочитаемый способ связи/) || ''
              finished_data << ResumeContact.new(contact_type: :phone, value: val.to_s, preferred: pref&.present?)
            elsif line =~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
              val = line.match /[\w\@.]{3,}/
              pref = line.match(/предпочитаемый способ связи/) || ''
              finished_data << ResumeContact.new(contact_type: :email, value: val.to_s, preferred: pref&.present?)
            elsif line =~ /Skype:/
              val = line.match(/Skype: ([\w\:_]+)/) || [""]
              pref = line.match(/предпочитаемый способ связи/) || ''
              finished_data << ResumeContact.new(contact_type: :skype, value: val[1], preferred: pref&.present?)
            end
          end
        end
        finished_data
      end

      def additional_contacts(file)
        finished_data = []
        parse_data(file, { start: /родил/, end: /Желаемая должность и зарплата/}) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = temp[(start_index.first + 1)..(end_index.first - 1)].map(&:to_s)
          data.each do |line|
            if line.match(/ICQ|Free-lance|Facebook|LinkedIn/)
              finished_data << {link: line.split(': ').last}
            end
          end
        end
        finished_data
      end

      def city(file)
        file.paragraphs.each do |p|
          return p.text.to_s.split(': ').last.to_s.squish if p.text.match(/Проживает:/)
        end
        nil
      end

      def photo
        file = Tempfile.new(['photo', '.png'], 'public/uploads/tmp', :encoding => 'ascii-8bit')
        Zip::File.open(path) do |zip_file|
          entry = zip_file.glob('word/media/image1.*').first
          file << entry.get_input_stream.read
        end
        file.rewind
        file
      end
    end
  end
end