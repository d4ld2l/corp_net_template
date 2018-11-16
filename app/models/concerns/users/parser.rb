module Users
  module Parser
    extend ActiveSupport::Concern

    included do
      def update_from_league_api(data, legal_unit, manager)
        profile = self.profile
        department, position, office = nil
        if data[:practice]
          department = Department.find_or_initialize_by(name_ru: data[:practice])
          department.code = data[:practice] unless department.code
          department_attributes = { profile_attributes: { default_legal_unit_employee_attributes: {
            default_legal_unit_position_attributes: {
              department: department
            }
          } } }
        end
        if data[:position]
          position = Position.find_or_initialize_by(name_ru: data[:position])
          position.code = data[:position] unless position.code
          position_attributes = { profile_attributes: { default_legal_unit_employee_attributes: {
            default_legal_unit_position_attributes: {
              position: position
            }
          } } }
        end
        if data[:office]
          office = Office.find_or_initialize_by(name: data[:office])
          office_attributes = { profile_attributes: { default_legal_unit_employee_attributes: {
            office: office
          } } }
        end
        user_attr = {
          profile_attributes: {
            id: profile&.id,
            surname: data[:lastName],
            name: data[:firstName],
            middlename: data[:secondName],
            birthday: data[:birthday] ? Date.parse(data[:birthday]) : nil,
            phone_number_private: data.dig(:phone, :personal),
          }
        }
        if profile&.default_legal_unit_employee
          user_attr.merge!(
            { profile_attributes: {
              default_legal_unit_employee_attributes: {
                id: profile&.default_legal_unit_employee&.id,
                legal_unit_id: legal_unit.id }
            } })
          if profile&.default_legal_unit_employee&.legal_unit_employee_position
            user_attr.merge!()
          end
        end
        self.update_attributes(user_attr)
      end
    end
  end
end