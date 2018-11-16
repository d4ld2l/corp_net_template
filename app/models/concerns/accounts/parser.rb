# TODO: USE UNUSED

module Accounts
  module Parser
    extend ActiveSupport::Concern

    included do
      def update_from_league_api(data, legal_unit, manager)
        if data[:practice]
          department = Department.find_or_initialize_by(name_ru: data[:practice])
          department.code = data[:practice] unless department.code
          department_attributes = {
            default_legal_unit_employee_attributes: {
              default_legal_unit_position_attributes: {
                department: department
              }
            }
          }
        end
        if data[:position]
          position = Position.find_or_initialize_by(name_ru: data[:position])
          position.code = data[:position] unless position.code
          position_attributes = {
            default_legal_unit_employee_attributes: {
              default_legal_unit_position_attributes: {
                position: position
              }
            }
          }
        end
        if data[:office]
          office = Office.find_or_initialize_by(name: data[:office])
          office_attributes = {
            default_legal_unit_employee_attributes: {
              office: office
            }
          }
        end
        account_attrs = {
          surname: data[:lastName],
          name: data[:firstName],
          middlename: data[:secondName],
          birthday: data[:birthday] ? Date.parse(data[:birthday]) : nil,
          account_phones_attributes: if data.dig(:phone, :personal)
                                       [
                                         {
                                           kind: 'personal',
                                           number: data.dig(:phone, :personal)
                                         }
                                       ]
                                     else
                                       []
                                     end
        }
        if default_legal_unit_employee
          account_attrs[:default_legal_unit_employee_attributes] = {
              id: default_legal_unit_employee&.id,
              legal_unit_id: legal_unit.id
            }
          if default_legal_unit_employee&.legal_unit_employee_position
            account_attrs.merge!
          end
        end
        update_attributes(account_attrs)
      end
    end
  end
end