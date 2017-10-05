module LegalUnitEmployee::TransfersHistory
  extend ActiveSupport::Concern

  included do

    def transfers_history
      transfers_versions_list.map{|x| get_transfers_from_version(x)}.flatten
    end

    private

    def get_transfers_from_version(version)
      res = []
      version.changeset.each_key do |v|
        transfer = {transfer_type:nil, transfer_date:version.created_at.to_date, previous_value:nil, next_value:nil}
        if v =='manager_id'
          transfer[:transfer_type] = 'Управленческий учет'
          transfer[:previous_value] = Profile.find(version.changeset[v][0])&.full_name if version.changeset[v][0]
          transfer[:next_value] = Profile.find(version.changeset[v][1])&.full_name if version.changeset[v][1]
        elsif v == 'pay'
          transfer[:transfer_type] = 'Оклад'
          transfer[:previous_value] = version.changeset[v][0]
          transfer[:next_value] = version.changeset[v][1]
        elsif v == 'position_code'
          transfer[:transfer_type] = 'Должность'
          transfer[:previous_value] = Position.find_by(code: version.changeset[v][0])&.name_ru if version.changeset[v][0]
          transfer[:next_value] = Position.find_by(code: version.changeset[v][1])&.name_ru if version.changeset[v][1]
        elsif v == 'department_code'
          transfer[:transfer_type] = 'Подразделение'
          transfer[:previous_value] = Department.find_by(code:version.changeset[v][0])&.name_ru if version.changeset[v][0]
          transfer[:next_value] = Department.find_by(code:version.changeset[v][1])&.name_ru if version.changeset[v][1]
        elsif v == 'wage_rate'
          transfer[:transfer_type] = 'График'
          transfer[:previous_value] = version.changeset[v][0]
          transfer[:next_value] = version.changeset[v][1]
        end
        res << transfer if transfer[:transfer_type]
      end
      return res
    end

    def transfers_versions_list
      items = []
      items << PaperTrail::Version.all.where(item_type:'LegalUnitEmployee').where(item_id:self.id).where(event:'update').to_a
      items << PaperTrail::Version.all.where(item_type:'LegalUnitEmployeePosition').where(item_id:self&.legal_unit_employee_position.id).where(event:'update').to_a
      items.flatten.sort_by{|x| x[:created_at]}.reverse
    end
  end
end
