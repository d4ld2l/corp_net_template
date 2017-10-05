class EventDecorator < Draper::Decorator
  delegate_all

  def participants
    event_participants.map do |ep|
      profile = ep&.participant&.profile
      {
          email:  ep.email || ep&.participant&.email,
          photo: profile&.photo,
          fullname: profile&.full_name,
          position_name: ep&.participant&.profile&.default_legal_unit_employee&.position&.position&.name_ru,
          departments_chain: profile&.departments_chain
      }
    end
  end

  def created_by
    user = object.created_by
    return nil unless user
    {
        email:  user&.email,
        photo: user&.profile&.photo,
        fullname: user&.profile&.full_name,
        position_name: user&.profile&.default_legal_unit_employee&.position&.position&.name_ru,
        departments_chain: user&.profile&.departments_chain
    }
  end

end
