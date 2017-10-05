class DepartmentDecorator < Draper::Decorator
  delegate_all

  def to_node
    attributes.merge({children: children.map { |c| c.decorate.to_node },
                           participants: participants_hash,
                           participants_count: legal_unit_employee_positions.count,
                           logo: logo.as_json({})
                     })
  end

  def participants_hash
    legal_unit_employee_positions.includes(:legal_unit_employee).map do |x|
      profile = x&.legal_unit_employee&.profile
      {
          id: profile&.user&.id,
          profile_id: profile.id,
          email: profile.user.email,
          email_private: profile.email_private,
          email_work: x.legal_unit_employee.email_work,
          email_corporate: x.legal_unit_employee.email_corporate,
          photo: profile.photo,
          fullname: profile.full_name, #TODO: delete, deprecated
          full_name: profile.full_name,
          position_name: x.position.name_ru,
          departments_chain: profile.departments_chain
      }
    end
  end

end
