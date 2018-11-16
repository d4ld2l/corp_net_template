require_relative '../base_parser'

module Parsers
  module HH
    class ResumeDoc < Parsers::HH::BaseResumeParser
      def parse
        doc = open_file.whole_contents.split(/\n/)

        HashWithIndifferentAccess.new(full_name: full_name(doc),
                                      sex: gender { doc },
                                      birthdate: birthday { doc.second },
                                      #phone: phone { doc.fourth },
                                      #email: email(doc),
                                      desired_position: desired_position(doc),
                                      salary_level: salary_level(doc),
                                      professional_specializations_attributes: professional_specializations(doc),
                                      employment_type: parse_checkbox(doc, /Занятость/),
                                      working_schedule: parse_checkbox(doc, /График работы/),
                                      resume_work_experiences_attributes: experience(doc),
                                      resume_educations_attributes: education(doc),
                                      language_skills_attributes: language(doc),
                                      skill_list: skills(doc),
                                      skills_description: skills_description(doc),
                                      resume_source_id: ResumeSource.find_or_create_by(name:'HeadHunter').id)
      end

      def full_name(file)
        file.first.squish
      end

      def email(file)
        file.fifth.split('"').last.split('—').first.to_s.squish
      end

      def desired_position(file)
        parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.first )..(end_index.first - 1)] }
          return if data.nil?
    
          data.map(&:to_s).first.split('\\n').last
        end
      end

      def salary_level(file)
        parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.first + 1)..(end_index.first - 1)] }
          return if data.nil?
    
         data.map(&:to_s)[-2].split(/\t/).last.gsub(' ', '_').to_i
        end
      end

      def professional_specialization(file)
        super file, 1
      end

      def parse_checkbox(file, regexp)
        super file, regexp, 1
      end

      def experience(file)
        parse_data(file, { start: /Опыт работы/, end: /Образование/ }) do |start_index, end_index|
  
          finished_data = {}
          data = exception_handler { file[(start_index.first)..(end_index.first - 1)] }
          return if data.nil?
  
          data.each_with_index do |p, i|
            line = p.to_s.squish
    
            date = line.match(/((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4})\s—\s((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}|настоящее время)/)
                     .to_s.split('—')
    
            if date.any?
              company_namy ||= data[i + 2].squish
              website ||= data[i + 3].split(',').last.squish if data[i + 3].match(/w{3}/)
            end
    
            hash ||= { start_date: date.first&.squish ,
                        end_date: date.second&.squish,
                        company_name: company_namy || nil,
                        website: website || nil }.compact

            finished_data[i] = hash.any? ? hash : nil
          end

          finished_data.compact
        end
      end

      def education(file)
        parse_data(file, { start: /Образование/, end: /Ключевые навыки/ }) do |start_index, end_index|
          finished_data = {}
          finished_data[:education_level] = { name: file[(start_index.first + 1)].to_s.squish }
          data = exception_handler { file[(start_index.first)..(end_index.first)] }
          return if data.nil?
          
          data.each_with_index do |array, i|
            split_array = array.to_s.split('\\n')
            if split_array.include?('Образование')
              finished_data[:education_level] = { name: split_array[split_array.index('Образование') + 1].to_s.squish }
            end
            finished_data[i] = {}
            
            split_array.each do |elem|
              finished_data[i] = {}
              if date ||= elem.split('\t').first.match(/\d{4}/)
                finished_data[i][:end_year] = date
              end
              
              if elem.split(',').size == 2 && (split_array[split_array.index(elem) + 1] == 'Ключевые навыки' || split_array[split_array.index(elem) + 1]&.match(/\d{4}/))
                finished_data[i - 1][:faculty_name] = elem.split(',').first.to_s.squish
                finished_data[i - 1][:speciality] = elem.split(',').second.to_s.squish
              end
              
              finished_data[finished_data.keys.last].values.any? ? nil : finished_data.delete(i)
            end
          end
          finished_data.compact
        end
      end

      def language(file)
        parse_data(file, { start: /Ключевые навыки/, end: /Навыки/ }) do |start_index, end_index|
          finished_data = {}
          
          data = exception_handler { file[(start_index.first)..(end_index.first)] }
          return if data.nil?

          data.each_with_index do |line, i|
            unless data[i] == data.last
              split_line = line.to_s.split(/\t/)
  
              language = if split_line.size == 2
                           split_line.last.split('—')
                         elsif line.split('—').size == 2
                           line.split('—')
                         end
  
              finished_data[i] = { language: language.first.to_s.squish,
                                   language_level: language.last.to_s.squish}
            end
          end
          last_elem = data.last.split('\\n').first.split('—')
          finished_data[finished_data.keys.last + 1] = { language: last_elem.first.to_s.squish,
                                                         language_level: last_elem.last.to_s.squish}
          finished_data
        end
      end

      def skills(file)
        parse_data(file, { start: /Навыки/, end: /Дополнительная информация/, without_block: /  •  Резюме обновлено/}) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.first)..(end_index.first)] }
          return if data.nil?
    
          data.delete_if(&:blank?).map {|e| e.to_s.split(/\t/)}.flatten.second.split('\\n').first.split
        end
      end

      def skills_description(file)
        parse_data(file, { start: /Дополнительная информация/, end: /Резюме обновлено/ }) do |start_index, end_index|
          temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
          data = exception_handler { temp[(start_index.first)..(end_index.first + 1)] }
          return if data.nil?
          
          data.map {|e| e.to_s.split(/\t/).map{ |e| e.split('\\n') } }.flatten[5..-2].join
        end
      end
    end
  end
end