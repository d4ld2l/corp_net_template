module LegalUnitEmployees
  module TransfersHistory
    extend ActiveSupport::Concern

    included do

      def transfers_history
        transfers_versions_list.map { |x| get_transfers_from_version(x) }.flatten
      end

      private

      def get_transfers_from_version(version)
        res = []
        version.changeset.each_key do |v|
          transfer = { transfer_type: nil, transfer_date: version.created_at.to_date, previous_value: nil, next_value: nil }
          if v == 'manager_id'
            transfer[:transfer_type] = 'Управленческий учет'
            before = version.changeset[v][0] ? Profile.where(id: version.changeset[v][0]).first : nil
            after = version.changeset[v][1] ? Profile.where(id: version.changeset[v][1]).first : nil
            transfer[:previous_value] = before&.full_name if before
            transfer[:next_value] = after&.full_name if after
          elsif v == 'wage'
            transfer[:transfer_type] = 'Заработная плата'
            transfer[:previous_value] = version.changeset[v][0]
            transfer[:next_value] = version.changeset[v][1]
          elsif v == 'position_code'
            transfer[:transfer_type] = 'Должность'
            before = version.changeset[v][0] ? Position.where(code: version.changeset[v][0]).first : nil
            after = version.changeset[v][1] ? Position.where(code: version.changeset[v][1]).first : nil
            transfer[:previous_value] = before&.name_ru if before
            transfer[:next_value] = after&.name_ru if after
          elsif v == 'department_code'
            transfer[:transfer_type] = 'Блок / Практика'
            before = version.changeset[v][0] ? Department.where(code: version.changeset[v][0]).first : nil
            after = version.changeset[v][1] ? Department.where(code: version.changeset[v][1]).first : nil
            transfer[:previous_value] = before&.block_and_practice_string if before
            transfer[:next_value] = after&.block_and_practice_string if after
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
        items << PaperTrail::Version.all.where(item_type: 'LegalUnitEmployee').where(item_id: self.id).where(event: 'update').to_a
        items << PaperTrail::Version.all.where(item_type: 'LegalUnitEmployeePosition').where(item_id: self&.legal_unit_employee_position&.id).where(event: 'update').to_a
        items.flatten.sort_by { |x| x[:created_at] }.reverse
      end
    end
  end
end
