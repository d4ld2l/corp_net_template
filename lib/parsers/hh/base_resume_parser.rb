class Parsers::HH::BaseResumeParser < Parsers::BaseParser

  def self.check_format(file)
    hh_regexp = /<p style=\"font-size:12pt;\"><span style=\"font-size:25pt;\">/i
    Docx::Document.open(file).paragraphs.map(&:to_html).join.match(hh_regexp) ? true : false
  end

  def full_name(file, index)
    file.paragraphs[index].text.to_s.squish
  end

  def gender
    genders = { 'Мужчина' => :male, 'Женщина' => :female }
    temp = genders[yield.split(',').first]
    temp = :undefined if temp.nil?
    temp
  end

  def birthday
    exception_handler { yield.split(',').last.split(' ')[1..3].join(' ').to_s.squish }
  end

  def phone
    yield.split('—').first.to_s.squish
  end

  def email(file, index)
    file.paragraphs[index].text.split('—').first.to_s.squish
  end

  def skype(file, index)
    file.paragraphs[index].text.match(/Skype/) ? file.paragraphs[index].text.gsub('Skype: ','') : nil
  end

  def additional_contacts(file, index)
    res = []
    i = 0
    p = file.paragraphs[index+i].text
    while (!p.match /Проживает:/) && (i < 10) && p&.present? do
      res << {link: p.split(': ').last}
      i+=1
      p = file.paragraphs[index+i].text
    end
    res
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
      salary = data.map(&:to_s).delete_if(&:empty?).last.sub(/(руб.|EUR|USD)/, '').gsub(/\D/, '')
      if ['', nil].include?(salary)
        nil
      else
        salary.to_i
      end
    end
  end

  def professional_specializations(file, doc_from = 0)
    result = []
    parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      data = exception_handler([]) { temp[(start_index.first + 1 - doc_from)..(end_index.first - 1)] }
      data = data.map(&:to_s).delete_if(&:empty?)[1..-1]
      i = 1
      area = data[0]
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
    end
    result
  end

  def specialization(file)
    result = []
    doc_from = 0
    parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      data = temp[(start_index.first + 1 - doc_from)..(end_index.first - 1)]
      return if data.nil?
      data = data.map(&:to_s).delete_if(&:empty?)[1..-1]
      i = 1
      area = data[0].gsub(' руб.', '')
      spec = ''
      while i < 6 do
        if data[i].to_s.match(/•/)
          spec += area
          spec += ' / '
          spec += data[i].gsub('• ', '')
          result += [spec]
          spec=''
        else
          area = data[i]
        end
        i+=1
      end
    end
    result.join('; ')
  end

  def parse_checkbox(file, regexp, doc_from = 0)
    parse_data(file, { start: /Желаемая должность и зарплата/, end: /Опыт работы/ }) do |start_index, end_index|
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      data = temp[(start_index.first + 1 - doc_from)..(end_index.first - 1)]
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
    finished_data = {}
    parse_data(file, { start: /Опыт работы/, end: /Образование/ }) do |start_index, end_index|
      data = file.paragraphs[(start_index.first + 1)..(end_index.first - 1)]
      data.each_with_index do |p, i|
        line = p.to_s.squish
        end_match = nil
        if start_match ||= line.match(/(Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}/)
          end_match = date_parse(line.split('—').last.match(/((Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)\s\d{4}|настоящее время)/).to_s)
          company_name ||= data[i + 3].text
          region = data[i + 4]&.text&.split(',')&.first&.to_s&.squish
          experience_description = ""
          data[i+6]&.each_text_run {|t| experience_description += t.to_s.squish + "<br>" unless t.to_s == ''}
          position ||= data[i + 5]&.text&.to_s&.squish
          website ||= data[i + 4]&.text&.split(',')&.second.to_s.squish
        end
        array ||= { start_date: date_parse(start_match&.to_s), end_date: end_match&.to_s, position: position,
                    region: region,  experience_description: experience_description, company_name: company_name || nil, website: website || nil}.compact

        finished_data[i] = array.any? ? array : nil
      end
    end
    finished_data.compact
  end

  def date_parse(date_string)
    if date_string && !date_string.match('/настоящее время/')
      result = date_string
      result.gsub!(/(Январь|Февраль|Март|Апрель|Май|Июнь|Июль|Август|Сентябрь|Октябрь|Ноябрь|Декабрь)/,
                   'Январь' => '01', 'Февраль' => '02', 'Март' => '03',
                   'Апрель' => '04', 'Май'=>'05', 'Июнь'=>'06',
                   'Июль'=> '07', 'Август'=>'08', 'Сентябрь'=>'09',
                   'Октябрь'=>'10', 'Ноябрь'=>'11', 'Декабрь'=>'12')
      result = "01.#{result}"
      Date.parse(result.gsub(' ', '.'))&.to_time&.to_s rescue nil
    else
      nil
    end
  end

  def convert_month(date_string)
    res = date_string
    months = [["января", "Jan"], ["февраля", "Feb"], ["марта", "Mar"],
              ["апреля", "Apr"], ["мая", "May"], ["июня", "Jun"],
              ["июля", "Jul"], ["августа", "Aug"], ["сентября", "Sep"],
              ["октября", "Oct"], ["ноября", "Nov"], ["декабря", "Dec"]]
    months.each do |cyrillic_month, latin_month|
      if res.match cyrillic_month
        res = res.gsub!(/#{cyrillic_month}/, latin_month)
      end
    end
    res
  end

  def education(file)
    finished_data = {}
    parse_data(file, { start: /Образование/, end: /Ключевые навыки|Повышение квалификации, курсы|Тесты, экзамены/ }) do |start_index, end_index|
      #finished_data[:education_level] = { school_name: file.paragraphs[(start_index.first + 1)].to_s.squish }
      education_level_id = EducationLevel.find_by(name: file.paragraphs[(start_index.first + 1)].to_s.squish).id
      data = file.paragraphs[(start_index.first + 2)..(end_index.first - 1)].in_groups_of(3)
      return if data.nil?

      data.each_with_index do |line, i|
        finished_data[i] = { end_year: line.first.to_s&.squish,
                             school_name: line.second.to_s&.squish,
                             faculty_name: line.third.to_s.split(',')&.first&.squish,
                             speciality: line.third.to_s.split(',')&.second&.squish,
                             education_level_id: education_level_id
        }
      end
    end
    finished_data
  end

  def education_level(file)
    result = nil
    parse_data(file, { start: /Образование/, end: /Ключевые навыки|Повышение квалификации, курсы|Тесты, экзамены/ }) do |start_index, end_index|
      result = EducationLevel.find_by(name: file.paragraphs[(start_index.first + 1)].to_s.squish)
    end
    result
  end

  def courses(file)
    finished_data = []
    parse_data(file, { start: /Повышение квалификации, курсы/, end: /Ключевые навыки|Дополнительная информация|Тесты, экзамены/}) do |start_index, end_index|
      data = file.paragraphs[(start_index.first+1)..(end_index.first-1)].in_groups_of(3)
      #return if data.nil?
      data.each_with_index do |line, i|
        finished_data << {
            name: line.second.to_s&.squish,
            company_name: line.third.to_s&.squish,
            end_year: line.first.to_s&.squish
        }
      end
    end
    finished_data
  end

  def certificates(file)
    finished_data = []
    parse_data(file, { start: /Электронные сертификаты/, end: /Ключевые навыки|Дополнительная информация/}) do |start_index, end_index|
      data = file.paragraphs[(start_index.first+1)..(end_index.first-1)].in_groups_of(3)
      #return if data.nil?
      data.each_with_index do |line, i|
        date = line.first ? "01.01.#{line.first}".to_date : nil
        names = line.second.node.children.map(&:text).select(&:present?)
        names.each do |name|
          finished_data << {
              name: name.squish,
              end_date: date
          }
        end
      end
    end
    finished_data
  end

  def language(file, prom_pdf = 0)
    finished_data = {}
    parse_data(file, { start: /Ключевые навыки/, end: /Навыки$/ }) do |start_index, end_index|
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      data = exception_handler([]) { temp[(start_index.first + 2 - prom_pdf)..(end_index.first - 1)] }
      #return if data.nil?
      data.each_with_index do |line, i|
        split_line = line.to_s.split('—')
        lang = Language.find_by(name: split_line.first.to_s.squish.sub(/Знание языков /, '').capitalize)
        lang_lev = LanguageLevel.find_by(name: split_line.last.to_s.squish.capitalize)
        if lang && lang_lev
          finished_data[i] = { language_id: lang&.id,
                               language_level_id: lang_lev&.id }
        end
      end
    end
    finished_data
  end

  def skills(file)
    result = []
    parse_data(file, { start: /Навыки/, end: /Дополнительная информация/, without_block: /  •  Резюме обновлено/ }) do |start_index, end_index|
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      data = exception_handler([]) { temp[(start_index.first + 1)..(end_index.first - 1)] }
      result = data.map {|e| e.to_s.split('  ')}.flatten
    end
    result
  end

  def skills_description(file, prom_pdf = 0)
    parse_data(file, {start:/Обо мне/, end://}) do |start_index, end_index|
      temp = file.respond_to?(:paragraphs) ? file&.paragraphs : file
      data = temp[(start_index.first + 1 - prom_pdf)..(end_index.first - 2)].map{|x| x&.to_html&.gsub('</p>','')&.gsub('<p style="font-size:12pt;">', '')&.gsub('</span>', '</p>')&.gsub('<span style="font-size:9pt;">', '<p>')}.join
      data
    end
  end

  def matching_checkboxes(matching, data)
    res = {}
    data.each_key do |key|
      res[matching[key]] = true
    end
    res
  end

  def employment_type(data)
    matching = {
        'полная занятость' => 'full_time',
        'частичная занятость' => 'part_time',
        'проектная работа' => 'temporary',
        'волонтерство' => 'volunteering',
        'стажировка' => 'probation'
    }
    matching_checkboxes(matching, data)
  end

  def working_schedule(data)
    matching = {
        'полный день' => 'full_day',
        'сменный график' => 'exchangeable',
        'гибкий график' => 'flextime',
        'удаленная работа' => 'remote',
        'вахтовый метод' => 'rotating'
    }
    matching_checkboxes(matching, data)
  end

  def preferred_contact_type(file, index)
    data = file.respond_to?(:paragraphs) ? file&.paragraphs : file
    regexp = /предпочитаемый способ связи/
    if data[4 - index].to_s.match(regexp)
      'phone'
    elsif data[5 - index].to_s.match(regexp)
      'email'
    elsif data[6 - index].to_s.match(regexp)
      'skype'
    else
      nil
    end
  end

  def recommendations(file)
    result = []
    parse_data(file, { start: /Дополнительная информация/, end: /Обо мне/ }) do |start_index, end_index|
      i = start_index[0]+2
      while i <= end_index[0]-1 do
        recommender = file.paragraphs[i+1].to_s.split(' (').first
        company_and_position = file.paragraphs[i].to_s + ' (' + file.paragraphs[i+1].to_s.split(' (').last
        result << {recommender_name: recommender, company_and_position: company_and_position}
        i+=3
      end
    end
    result
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
        end_index << i if end_index.empty?
      elsif text =~ /Резюме обновлено/
        end_index << i if end_index.empty?
      end
    end
    end_index << temp.size-1 if end_index.empty? && start_index.present?
    yield(start_index, end_index) if start_index.present? && end_index.present?
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
end