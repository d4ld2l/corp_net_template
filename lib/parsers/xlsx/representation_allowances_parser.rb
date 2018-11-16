require 'tempfile'
module Parsers
  class XLSX::RepresentationAllowancesParser
    attr_accessor :workbook, :worksheet

    def self.build(params)
      bids = params
      file = Tempfile.new(['Отчёт по представительским расходам', '.xlsx'])

      @workbook = RubyXL::Workbook.new
      @worksheet = @workbook[0]
      representation_allowance_build(bids)
      @workbook.write(file)
      file.path
    end

    private

    def self.representation_allowance_build(bids)
      @worksheet.insert_cell(0, 0, 'Отчёт о заявках сотрудников на получение сервиса Представительские расходы')
      @worksheet.insert_cell(2, 0, 'Дата и время формирования отчёта:')
      @worksheet.insert_cell(2, 3, I18n.l(DateTime.now))
      @worksheet.insert_cell(3, 0, 'Сервис')
      @worksheet.insert_cell(3, 3, 'Представительские расходы')

      @worksheet.insert_cell(5, 0, 'Номер заявки')
      @worksheet.insert_cell(5, 1, 'Статус заявки')
      @worksheet.insert_cell(5, 2, 'Исполнитель')
      @worksheet.insert_cell(5, 3, 'ФИО сотрудника')
      @worksheet.insert_cell(5, 4, 'Юридическое лицо')
      @worksheet.insert_cell(5, 5, 'Должность')
      @worksheet.insert_cell(5, 6, 'Код проекта')
      @worksheet.insert_cell(5, 7, 'Организация')
      @worksheet.insert_cell(5, 8, 'Дата и время встречи')
      @worksheet.insert_cell(5, 9, 'Цель встречи')
      @worksheet.insert_cell(5, 10, 'Результат встречи')
      @worksheet.insert_cell(5, 11, 'Сумма комппенсации')
      @worksheet.insert_cell(5, 12, 'Создатель заявки')
      @worksheet.insert_cell(5, 13, 'Дата и время создания')
      bids.each_with_index do |bid, index|
        customer_name = Customer.find_by(id: bid.information_about_participant&.customer_id)&.name

        @worksheet.insert_cell(6 + index, 0, bid.id)
        @worksheet.insert_cell(6 + index, 1, bid.bid_stage&.name)
        @worksheet.insert_cell(6 + index, 2, bid.manager&.full_name)
        @worksheet.insert_cell(6 + index, 3, bid.creator&.full_name)
        @worksheet.insert_cell(6 + index, 4, bid.legal_unit&.full_name)
        @worksheet.insert_cell(6 + index, 5, bid.creator_position)
        @worksheet.insert_cell(6 + index, 6, bid.information_about_participant&.project&.charge_code)
        @worksheet.insert_cell(6 + index, 7, customer_name)
        @worksheet.insert_cell(6 + index, 8, bid.meeting_information&.starts_at ? I18n.l(bid.meeting_information&.starts_at) : '')
        @worksheet.insert_cell(6 + index, 9, bid.meeting_information&.aim)
        @worksheet.insert_cell(6 + index, 10, bid.meeting_information&.result)
        @worksheet.insert_cell(6 + index, 11, bid.meeting_information&.amount)
        @worksheet.insert_cell(6 + index, 12, bid.creator&.full_name)
        @worksheet.insert_cell(6 + index, 13, I18n.l(bid.created_at))
      end
    end
  end
end