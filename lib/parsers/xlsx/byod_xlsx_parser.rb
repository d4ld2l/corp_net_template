module Parsers
  class XLSX::ByodXlsxParser
    require 'simple_xlsx_reader'

    def initialize(path)
      @xlsx = SimpleXlsxReader.open(path)
    end

    def create_bids
      line = @xlsx.sheets.first.rows.map{|r| r[1]}
      numberOfActiveLines = 1
      arrayCell = []
      while line[numberOfActiveLines] != nil do
        @xlsx.sheets.first.rows[numberOfActiveLines].each do |cell|
          cell = nil if cell == ''
          arrayCell.push(cell)
        end
        author_id = surname(arrayCell[1])
        manager_id = surname(arrayCell[2])
        assistant_id = surname(arrayCell[12])
        matching_account_id= surname(arrayCell[11])
        creator_id = surname(arrayCell[7])
        device_model = arrayCell[14]
        device_inventory_number = arrayCell[13]
        creator_position = Account.find(creator_id)&.default_legal_unit_employee&.position&.position&.name_ru
        legal_unit_id = Account.find(creator_id)&.default_legal_unit_employee&.legal_unit&.id
        manager_position = Account.find(manager_id)&.default_legal_unit_employee&.position&.position&.name_ru
        service_id = Service.find_by(name: arrayCell[0]).id
        bid_status =  arrayCell[5]
        bid_stages_group_id = Service.find_by(name: arrayCell[0])&.bid_stages_group_id
        bid_code = BidStage.find_by(name: bid_status, bid_stages_group_id:  bid_stages_group_id)&.code
        if arrayCell[15] == nil
          compensation_amount = 0
        else
          compensation_amount = arrayCell[15]
        end
        if arrayCell[6].to_s == 'Выкуп ноутбука из helpDesc'
          byod_type = 'buy_out'
        elsif arrayCell[6].to_s == 'Покупка нового ноутбука'
          byod_type = 'new_device'
        end
        if arrayCell[10].to_s == '-'
          project_id = nil
        else
          project_id = Project.find_by(charge_code: arrayCell[10].to_s)
        end
        bid = Bid.new(service_id: service_id, author_id: author_id, manager_id:  manager_id, manager_position: manager_position,
                      legal_unit_id: legal_unit_id, matching_user_id: matching_account_id,
                      assistant_id: assistant_id, creator_id: creator_id, creator_position: creator_position)
        bid.byod_information = ByodInformation.new(byod_type: byod_type, project_id: project_id, device_model: device_model,
                                                   device_inventory_number: device_inventory_number, compensation_amount: compensation_amount)
        bid.bid_stage = BidStage.find_by(code: bid_code, bid_stages_group_id: bid_stages_group_id)
        bid.save
        pp(bid.errors.inspect)
        numberOfActiveLines +=1;
        arrayCell = []
      end
    end

    def surname(arrayCell)
      fullName = arrayCell.split
      Account.find_by(surname: fullName[0], name: fullName[1], middlename: fullName[2]).id #&.user_id
    end
  end
end
