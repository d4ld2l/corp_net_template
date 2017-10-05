require 'docx'
require 'pdf-reader'
require 'msworddoc-extractor'
require 'nokogiri'

module Parsers
  class BaseParser
    # self.abstract_class = true

    attr_accessor :path, :url, :format

    def initialize(options = {})
      @path = options[:path]
      @url = options[:url]
      @format = options[:format]
    end

    def full_name(file, index)
      file.paragraphs[index].to_s.squish
    end

    def gender
      genders = { 'Мужчина' => :female, 'Женщина' => :male }
      temp = genders[yield.split(',').first]
      temp = :undefined if temp.nil?
      temp
    end

    def birthday
      yield.split(',').last.split(' ')[1..3].join(' ').to_s.squish
    end

    def phone
      yield.split('—').first.to_s.squish
    end

    def email(file, index)
      file.paragraphs[index].text.split('—').first.to_s.squish
    end

    def desired_position(file)
      parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 1)..(end_index.first - 1)] }
        return if data.nil?
    
        data.map(&:to_s).first
      end
    end

    def salary_level(file)
      parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 1)..(end_index.first - 1)] }
        return if data.nil?
    
        data.map(&:to_s).delete_if(&:empty?).last.sub(/(руб.|EUR|USD)/, '').gsub(' ', '_').to_i
      end
    end

    def professional_specialization(file, doc_from = 0)
      parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 1 - doc_from)..(end_index.first - 1)] }
        return if data.nil?
        #TODO
        hash = { professional_specialization: { professional_area: {}} }
        hash[:professional_specialization][:name] = data.map(&:to_s).delete_if(&:empty?).second
        data.map(&:to_s).delete_if(&:empty?)[2..-2].each_with_index do |elem, i|#.last.sub(/(руб.|EUR|USD)/, '').gsub(' ', '_').to_i
          unless elem.match(/(Занятость|График работы|Желательное время в пути до работы)/)
            hash[:professional_specialization][:professional_area][i] = elem
          end
        end
        hash
      end
    end

    def parse_checkbox(file, regexp, doc_from = 0)
      parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 1 - doc_from)..(end_index.first - 1)] }
        return if data.nil?
        hash = {}
        data.map(&:to_s).delete_if(&:empty?).each_with_index do |elem, i|
          
          if elem.match(regexp)
            elem.split(':').second.split(',').map(&:squish).each do |e|
              hash[e] = true
            end
          end
        end
        hash.as_json
      end
    end

    def experience(file)
      parse_data(file, { start: /Опыт работы/, end: /Образование/ }) do |start_index, end_index|
        finished_data = {}
        data = exception_handler { file.paragraphs[(start_index.first + 1)..(end_index.first - 1)] }
        return if data.nil?
        
        data.each_with_index do |p, i|
          line = p.to_s.squish
      
          end_match = nil
          if start_match ||= line.match(/(Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}/)
            end_match = line.split('—').last.match(/((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}|настоящее время)/)
            company_name ||= data[i + 3].text
            website ||= data[i + 4]&.text&.split(',')&.second.to_s.squish
          end
          
          array ||= { start_date: start_match&.to_s, end_date: end_match&.to_s,
                      company_name: company_name || nil, website: website || nil}.compact

          finished_data[i] = array.any? ? array : nil
        end

        finished_data.compact
      end
    end

    def education(file)
      parse_data(file, { start: /Образование/, end: /Ключевые навыки/ }) do |start_index, end_index|
        finished_data = {}
        finished_data[:education_level] = { name: file.paragraphs[(start_index.first + 1)].to_s.squish }
        data = exception_handler { file.paragraphs[(start_index.first + 2)..(end_index.first - 1)].in_groups_of(3) }
        return if data.nil?
        
        data.each_with_index do |line, i|
          finished_data[i] = { end_year: line.first.to_s&.squish,
                               faculty_name: line.third.to_s.split(',')&.first&.squish,
                               speciality: line.third.to_s.split(',')&.second&.squish }
        end
        finished_data
      end
    end
    
    def language(file, prom_pdf = 0)
      parse_data(file, { start: /Ключевые навыки/, end: /Навыки/ }) do |start_index, end_index|
        finished_data = {}
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 2 - prom_pdf)..(end_index.first - 1)] }
        return if data.nil?
    
        data.each_with_index do |line, i|
          split_line = line.to_s.split('—')
          finished_data[i] = { language: split_line.first.to_s.squish.sub(/Знание языков /, ''),
                               language_level: split_line.last.to_s.squish}
        end
        finished_data
      end
    end

    def skills(file)
      parse_data(file, { start: /Навыки/, end: /Дополнительная информация/, without_block: /  •  Резюме обновлено/ }) do |start_index, end_index|
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 1)..(end_index.first - 1)] }
        return if data.nil?
        
        data.map {|e| e.to_s.split }.flatten
      end
    end

    def skills_description(file, prom_pdf = 0)
      parse_data(file, { start: /Обо мне/, end: // }) do |start_index, end_index|
        temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
        data = exception_handler { temp[(start_index.first + 1 - prom_pdf)..(end_index.first - 1)] }
        return if data.nil?
        
        data.map {|e| e.to_s }.join
      end
    end
    
    protected

    def parse_data(file, regexp = {})
      start_index = []
      end_index = []
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      temp.each_with_index do |page, i|
        text = page.respond_to?(:text) ? page.text : page
        start_index << i if text =~ regexp[:start]
        # end_index.push(i) if (text =~ regexp[:without_block] && !(text =~ regexp[:end]))
        # end_index << i if text =~ regexp[:end]
        if text =~ regexp[:end]
          end_index << i
        elsif text =~ /Резюме обновлено/
          end_index << i
        end
      end
      
      yield(start_index, end_index)
    end
    
    def open_file
      case format
      when 'docx'
        Docx::Document.open(path || url)
      when 'doc'
        MSWordDoc::Extractor.load(path || url)
      when 'pdf'
        PDF::Reader.new(path || url)
      when 'rtf'
        'for the future'
      else
        raise ArgumentError, "Extension .#{format} of this file is unsupported, sorry bro"
      end
    end

    def exception_handler
      begin
        yield
      rescue
        return
      end
    end
  end
end
