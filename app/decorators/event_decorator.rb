class EventDecorator < Draper::Decorator
  delegate_all

  def participants_list
    event_participants.map do |ep|
      account = ep&.participant
      {
          event_participant_id: ep.id, # TODO: delete
          id: ep.id,
          account_id: ep&.participant&.id,
          email:  ep&.email || ep&.participant&.email,
          photo: account&.photo,
          fullname: account&.full_name,
          position_name: account&.default_legal_unit_employee&.position&.position&.name_ru,
          departments_chain: account&.departments_chain
      }
    end
  end

  def created_by
    account = object.created_by
    return nil unless account
    {
        email:  account&.email,
        photo: account&.photo,
        fullname: account&.full_name,
        position_name: account&.default_legal_unit_employee&.position&.position&.name_ru,
        departments_chain: account&.departments_chain
    }
  end

end
