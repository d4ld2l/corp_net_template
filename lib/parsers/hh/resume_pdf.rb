require_relative '../base_parser'
require 'active_support/core_ext/array/grouping.rb'

module Parsers
  module HH
    class ResumePdf < Parsers::HH::BaseResumeParser
      def parse
        pdf = open_file

        paragraphs = []
        pdf.pages.each do |page|
          lines = page.text.scan(/^.+/)
          lines.each do |line|
            unless line.match(/Резюме обновлено/)
              paragraphs << "#{line}".squish
            end
          end
        end

        HashWithIndifferentAccess.new(first_name: paragraphs.first.split(' ')[1],
                                      middle_name: paragraphs.first.split(' ')[2],
                                      last_name: paragraphs.first.split(' ')[0],
                                      sex: gender { paragraphs },
                                      city: city(paragraphs),
                                      birthdate: birthday { paragraphs.second },
                                      #phone: phone(paragraphs),
                                      #email: email(paragraphs),
                                      #skype: skype(paragraphs),
                                      #preferred_contact_type: preferred_contact_type(paragraphs, 2),
                                      additional_contacts_attributes: additional_contacts(paragraphs),
                                      professional_specializations: professional_specializations(paragraphs),
                                      specialization: specialization(paragraphs),
                                      desired_position: desired_position(paragraphs),
                                      position: desired_position(paragraphs),
                                      salary_level: salary_level(paragraphs),
                                      employment_type: employment_type(parse_checkbox(paragraphs, /Занятость/)),
                                      working_schedule: working_schedule(parse_checkbox(paragraphs, /График работы/)),
                                      #TODO: resume_work_experiences_attributes: experience(paragraphs),
                                      #TODO: resume_educations_attributes: education(paragraphs),
                                      language_skills_attributes: language(paragraphs),
                                      #TODO: skill_list: skills(paragraphs),
                                      skills_description: skills_description(paragraphs),
                                      resume_source_id: ResumeSource.find_or_create_by(name:'HeadHunter').id)
      end

      def email(file)
        file.fourth.split('—').first.to_s
      end
      
      def gender
        genders = { 'Мужчина' => :male, 'Женщина' => :female }
        temp = genders[yield.split(',').flatten.second.split(',').first]
        temp = :undefined if temp.nil?
        temp
      end

      def city(file)
        result = nil
        file[4, 16].each do |x|
          if x.match(/Проживает:/)
            result = x.split(': ').last
          end
        end
        result
      end

      def skype(file)
        result = nil
        file[4, 16].each do |x|
          if x.match(/Skype: /)
            result = x.split(': ').last
          end
        end
        result
      end

      def additional_contacts(file)
        result = []
        file[3, 15].each do |x|
          if x.match(/Facebook: |LinkedIn: |Мой круг: |Free-lance: |LiveJournal: |Другой сайт: /)
            result << {link: x.split(': ').last}
          end
        end
        result
      end

      def professional_specializations(file)
        parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
          data = exception_handler { file[start_index.first + 1, end_index.first - 1] }
          return if data.nil?
          data = data.map(&:to_s).delete_if(&:empty?)[1..-1]
          result = []
          i = 1
          area = data[0].gsub(' руб.', '')
          while i < 6 do
            if data[i].to_s.match(/•/)
              p_area = ProfessionalArea.find_or_create_by(name: area)
              p_spec = ProfessionalSpecialization.find_or_create_by(name: data[i].gsub('• ', ''), professional_area_id: p_area.id)
              result << p_spec
            else
              area = data[i]
            end
            i+=1
          end
          puts result
          result
        end
      end

      def birthday
        Date.parse(convert_month(yield.split(',').last.split(' ')[1..3].join(' ').to_s.squish))
      end
      
      def phone(file)
        file.third.gsub('— ', ' ').split(' ')[0..2].join
      end
      
      def desired_position(file)
        parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.first + 1)..(end_index.first - 1)] }
          return if data.nil?
    
          data.map(&:to_s).first.gsub(/\d/, '').squish
        end
      end

      def salary_level(file)
        parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.first + 1)..(end_index.first - 1)] }
          return if data.nil?
          
          t = data.map(&:to_s).delete_if(&:empty?)
          salary = if t.first.gsub(/\D/, '').squish.blank?
                     t.second.gsub(/\D/, '').squish.to_i
                   else
                     t.first.gsub(/\D/, '').squish.to_i
                   end
          salary
        end
      end

      def experience(file)
        parse_data(file, { start: /Опыт работы/, end: /Образование/ }) do |start_index, end_index|
          finished_data = {}
          data = exception_handler { file[(start_index.first + 1)..(end_index.first - 1)].in_groups_of(3) }
          return if data.nil?

          temp = []

          data.each_with_index do |array, i|
            array.each do |p|
              line = p.to_s.squish

              company ||= data[i] if start_match ||= line.match(/(Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}/)

              temp << company || nil
            end
          end

          temp.compact.uniq.each_with_index do |elem, i|
            first = elem.first.match(/(Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}/)
            second = elem.second.match(/(Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}/)

            parsed_data = check_elem_array_for_company(elem: elem, first: first, second: second, temp: temp)

            finished_data[i] = HashWithIndifferentAccess.new(start_date: parsed_data[:start_date], end_date: parsed_data[:end_date],
                                                             company_name: parsed_data[:company_name].squish, website: parsed_data[:website]&.to_s)

            finished_data.delete(i) if finished_data[i].values.compact.empty?
          end
          finished_data
        end
      end

      def education(file)
        parse_data(file, { start: /Образование/, end: /Ключевые навыки/ }) do |start_index, end_index|
          finished_data = {}
          finished_data[:education_level] = { school_name: file[(start_index.first + 1)].to_s.squish }
          data = exception_handler { file[(start_index.first + 2)..(end_index.first - 2)].in_groups_of(3) }
          return if data.nil?
    
          data.each_with_index do |array, i|
            array.compact!
            finished_data[i] = { end_year: array.first.to_s.match(/\d{4}/)&.to_s&.squish,
                                 #faculty_name: array.second.to_s.squish.split(',').first,
                                 faculty_name: array.last.to_s.split(',').first.squish,
                                 speciality: array.last.to_s.split(',').second&.squish }
          end
          finished_data
        end
      end
      
      def language(file)
        super file, 0
      end

      def skills(file)
        parse_data(file, { start: /Навыки/, end: /Дополнительная информация/ }) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.last)..(end_index.last - 1)] }
          return if data.nil?
          
          array = data.map {|e| e.to_s.sub(/Навыки/, '').split}.flatten
          index = exception_handler { (array.index('Дополнительная') - 1) } || -1
          array[0..index]
        end
      end

      def skills_description(file)
        super(file, 1)&.sub('Обо мне ', '')
      end
      
      private
      
      def check_elem_array_for_company(options = {})
        options[:website] = options[:elem].map{ |e| e.match(/(http(s)?:\/\/)?([\w\d]+\.)?[\w\d]+\.\w+\/?.+/)&.to_s }&.compact&.first
        check_second_elem_array(options) do |_|
          if options[:elem].first.split('—').size == 2 && options[:first]
            start_date ||= options[:first]
            unless end_date ||= options[:elem].first.split('—').last.match(/((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}|настоящее время)/)
              name ||= options[:elem].first.split('—').last
              end_date ||= options[:elem].second.match(/((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}|настоящее время)/)
            end
          end
          { start_date: start_date&.to_s || nil, end_date: end_date&.to_s || nil, company_name: name || nil, website: options[:website] || nil  }
        end
      end

      def check_second_elem_array(options)
        hash = yield

        if options[:elem].second.split('—').size == 2 && options[:second]
          hash[:start_date] ||= options[:second]
          unless hash[:end_date] ||= options[:elem].second.split('—').last.match(/((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}|настоящее время)/)
            hash[:company_name] ||= options[:elem].second.split('—').last
            hash[:end_date] ||= options[:elem].third.split[0..1].join
          end
        elsif options[:elem].second.split('—').size == 1 && options[:second]
          hash[:start_date] ||= options[:second]
          hash[:company_name] ||= options[:elem].third if hash[:company_name].blank?
          hash[:end_date] ||= options[:temp].compact[options[:temp].compact.index(options[:elem]) + 1].first.split[0..1].join
        end

        { start_date: hash[:start_date], end_date: hash[:end_date], company_name: hash[:company_name, ], website: options[:website] || nil }
      end
    end
  end
end
