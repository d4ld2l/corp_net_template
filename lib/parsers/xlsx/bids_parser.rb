require 'tempfile'
module Parsers
  class XLSX::BidsParser
    attr_accessor :workbook, :worksheet

    def self.build(params)
      bids = params
      file = Tempfile.new(['BYOD_отчёт', '.xlsx'])

      @workbook = RubyXL::Workbook.new
      @worksheet = @workbook[0]
      byod_build(bids)
      @workbook.write(file)
      file.path
    end

    private

    def self.get_byod_ru_name(byod_type)
      ru_names = {'new_device' => 'Покупка нового ноутбука', 'buy_out' => 'Выкуп ноутбука из helpDesk'}
      ru_names[byod_type]
    end

    def self.byod_build(bids)
      @worksheet.insert_cell(0, 0, 'Отчёт о заявках сотрудников на получение сервиса BYOD')
      @worksheet.insert_cell(2, 0, 'Дата и время формирования отчёта:')
      @worksheet.insert_cell(2, 3, I18n.l(DateTime.now))
      @worksheet.insert_cell(3, 0, 'Сервис')
      @worksheet.insert_cell(3, 3, 'BYOD')

      @worksheet.insert_cell(5, 0, 'Номер заявки')
      @worksheet.insert_cell(5, 1, 'Статус заявки')
      @worksheet.insert_cell(5, 2, 'Исполнитель')
      @worksheet.insert_cell(5, 3, 'Тип заявки')
      @worksheet.insert_cell(5, 4, 'ФИО сотрудника') 
      @worksheet.insert_cell(5, 5, 'Юридическое лицо')
      @worksheet.insert_cell(5, 6, 'Должность')
      @worksheet.insert_cell(5, 7, 'Код проекта')
      @worksheet.insert_cell(5, 8, 'Модель ноутбука')
      @worksheet.insert_cell(5, 9, 'Инвентаризационный номер')
      @worksheet.insert_cell(5, 10, 'Сумма компенсации')
      @worksheet.insert_cell(5, 11, 'Согласующий')
      @worksheet.insert_cell(5, 12, 'Ассистент')
      @worksheet.insert_cell(5, 13, 'Создатель заявки')
      @worksheet.insert_cell(5, 14, 'Дата и время создания')
      bids.each_with_index do |bid, index|
        assistant_name = bid.assistant_id.present? ? Account.find(bid.assistant_id).full_name : ' '

        @worksheet.insert_cell(6 + index, 0, bid.id)
        @worksheet.insert_cell(6 + index, 1, bid.bid_stage&.name)
        @worksheet.insert_cell(6 + index, 2, bid.manager&.full_name)
        @worksheet.insert_cell(6 + index, 3, get_byod_ru_name(bid.byod_information.byod_type))
        @worksheet.insert_cell(6 + index, 4, bid.creator&.full_name) 
        @worksheet.insert_cell(6 + index, 5, bid.legal_unit&.full_name)
        @worksheet.insert_cell(6 + index, 6, bid.creator_position)
        @worksheet.insert_cell(6 + index, 7, bid.byod_information.project&.charge_code)
        @worksheet.insert_cell(6 + index, 8, bid.byod_information.device_model)
        @worksheet.insert_cell(6 + index, 9, bid.byod_information.device_inventory_number)
        @worksheet.insert_cell(6 + index, 10, bid.byod_information.compensation_amount)
        @worksheet.insert_cell(6 + index, 11, bid.manager&.full_name)
        @worksheet.insert_cell(6 + index, 12, assistant_name)
        @worksheet.insert_cell(6 + index, 13, bid.creator&.full_name)
        @worksheet.insert_cell(6 + index, 14, I18n.l(bid.created_at))
      end 
    end
  end
end