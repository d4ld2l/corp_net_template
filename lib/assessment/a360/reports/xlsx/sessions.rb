module Assessment::A360::Reports::Xlsx
  class Sessions
    def initialize(sessions)
      @sessions = sessions
    end

    def build
      file = Tempfile.new(["Оценочные сессии #{I18n.l(Date.today)}", '.xlsx'])
      @workbook = RubyXL::Parser.parse("lib/templates/xlsx/assessment_sessions_template.xlsx")
      @worksheet = @workbook[0]
      build_sessions(1)
      @workbook.write(file)
      file
    end

    private

    def build_sessions(index)
      cur_index = index
      @sessions.each do |c|
        participants_count = c.participants_count
        participants_count += 1 unless c.participants.pluck(:account_id).include?(c.account_id)

        @worksheet.insert_cell(cur_index, 0, c.name)
        @worksheet.insert_cell(cur_index, 1, I18n.t("activerecord.attributes.assessment_session.kind.#{c.kind}"))
        @worksheet.insert_cell(cur_index, 2, c.account&.full_name)
        @worksheet.insert_cell(cur_index, 3, I18n.t("activerecord.attributes.assessment_session.status.#{c.status}"))
        @worksheet.insert_cell(cur_index, 4, c.evaluations_count)
        @worksheet.insert_cell(cur_index, 5, participants_count)
        @worksheet.insert_cell(cur_index, 6, I18n.l(c.updated_at))
        @worksheet.insert_cell(cur_index, 7, c.due_date ? I18n.l(c.due_date) : nil)
        @worksheet.insert_cell(cur_index, 8, c.created_by&.full_name)
        cur_index += 1
      end
    end
  end
end