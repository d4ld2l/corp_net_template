require 'tempfile'
module Parsers
  #TODO add < XLSX::BaseXlsxParser after migrate to rubyXL
  class XLSX::SurveyResultParser
    attr_accessor :workbook, :worksheet

    def self.build(params)
      survey = params
      file = Tempfile.new(["Опрос." + survey.name, ".xlsx"])

      @workbook = RubyXL::Workbook.new
      @worksheet = @workbook[0]

      results_build(survey)
      @workbook.write(file)
      file.path
    end

    private

    def self.results_build(survey)
      @worksheet.insert_cell(0, 0, survey.name)
      @worksheet.insert_cell(2, 0, 'Количество пользователей, прошедших опрос:')
      @worksheet.insert_cell(2, 1, survey.participants_passed_count)
      @worksheet.insert_cell(3, 0, 'Дата публикации опроса')
      @worksheet.insert_cell(3, 1, I18n.l(survey.published_at))
      @worksheet.insert_cell(4, 0, 'Тип опроса')
      @worksheet.insert_cell(4, 1, I18n.t("activerecord.enum.survey_type.#{survey.survey_type}"))
      survey.questions.each.with_index(1) do |q, i|
        @worksheet.insert_cell(6, i, "Вопрос #{i}")
        @worksheet.insert_cell(7, i, ActionView::Base.full_sanitizer.sanitize(q.wording))
      end
      @worksheet.insert_cell(7, 0, 'ФИО пользователя')
      position_from_top = 7
      results = survey.survey_results
      results.each.with_index(1) do |sr, index|
        position_from_top += 1
        name = survey.anonymous? ? "Пользователь #{index}" : "#{sr.account&.full_name}"
        @worksheet.insert_cell(position_from_top, 0, name)
        max_position = position_from_top
        sr.survey_answers.each.with_index(1) do |sa, index|
          current_position = position_from_top
          sa.answers.each do |key, value|
            if value && key != 'own_answer'
              answer = OfferedVariant.find(key.to_i)
              @worksheet.insert_cell(current_position, index, "#{answer.position}. #{ActionView::Base.full_sanitizer.sanitize(answer.wording)}")
            elsif key == 'own_answer' && !sa.question.ban_own_answer? && !value.blank?
              @worksheet.insert_cell(current_position, index, "Свой ответ. #{value}")
            end
            current_position += 1
          end
          max_position = [max_position, current_position-1].max
        end
        position_from_top = max_position
      end
    end

    def self.simple_result_build(collection) # deprecated
      @worksheet.insert_cell(0, 1, 'Дата прохождения')
      collection.each_with_index do |survey_result, index|
        @worksheet.insert_cell(index + 1, 0, survey_result.account.full_name)
        @worksheet.insert_cell(index + 1, 1, I18n.l(survey_result.created_at))
        survey_result.questions.each_with_index do |question, i|
          @worksheet.insert_cell(0, i + 2, ActionView::Base.full_sanitizer.sanitize(question.wording))
          question.survey_answers.where(survey_result: survey_result).each do |elem|
            answer = nil
            elem.answers.each do |key, value|
              if value && key != 'own_answer'
                answer = OfferedVariant.find(key.to_i).wording
              elsif key == 'own_answer'
                answer = elem.answers['own_answer']
              end
            end

            @worksheet.insert_cell(index + 1, i + 2, answer)
          end
        end
      end
    end

    def self.complex_result_build(collection) # deprecated
      @worksheet.insert_cell(0, 0, collection.first.questions.first&.wording)
      @worksheet.insert_cell(1, 0, 'Количество пользователей, прошедших опрос:')
      @worksheet.insert_cell(1, 1, collection.pluck(:user_id).uniq.size)

      @worksheet.insert_cell(2, 0, 'Варианты ответов')
      @worksheet.insert_cell(2, 1, 'Количество ответивших')
      @worksheet.insert_cell(2, 2, 'Популярность ответа, %')

      grouped = {}
      i = 0
      collection.flat_map(&:survey_answers).map(&:answers).each do |hash|
        hash.each do |key, value|
          i += 1
          key = OfferedVariant.find(key.to_i).wording
          @worksheet.insert_cell(i + 2, 0, key) unless grouped[key]
          grouped[key] ? grouped[key].push(value) : grouped[key] = [value]
        end
        # i = 0
      end

      grouped.each {|key, value| grouped[key] = (value.reject {|e| !e}.size.to_f / collection.size) * 100}
      i = 0

      grouped.each do |key_percent, value|
        i += 1
        @worksheet.insert_cell(i + 2, 2, value)
        temp = []
        collection.group_by(&:survey_answers).each do |key, value|
          wording = OfferedVariant.find(key.map(&:answers).first&.reject {|_, v| v == false}.keys.first.to_i)&.wording
          temp.push(value.first.user.id) if key_percent == wording
        end
        @worksheet.insert_cell(i + 2, 1, temp.size)
      end
    end
  end
end