class DepartmentDecorator < Draper::Decorator
  delegate_all

  def to_node
    attributes.merge({children: children.map { |c| c.decorate.to_node },
                           participants: participants_hash,
                           participants_count: legal_unit_employee_positions.count,
                           logo: logo.as_json({}),
                           manager: manager.as_json(methods:[:position_name])
                     })
  end

  def participants_hash
    legal_unit_employee_positions.includes(:legal_unit_employee).map do |x|
      account = x&.legal_unit_employee&.account
      {
          id: account&.id,
          email: account.email_address,
          # email_private: account.email_private,
          email_work: x&.legal_unit_employee&.email_work,
          email_corporate: x&.legal_unit_employee&.email_corporate,
          photo: account.photo,
          fullname: account.full_name, #TODO: delete, deprecated
          full_name: account.full_name,
          position_name: x&.position&.name_ru,
          departments_chain: account.departments_chain
      }
    end
  end

end
