class SurveyDecorator < Draper::Decorator
  delegate_all

  def participants_list
    survey_participants.map do |ep|
      account = ep&.account
      {
          survey_participant_id: ep.id, # DEPRECATED TODO: destroy later
          id: ep.id,
          account_id: account&.id,
          email: ep&.account&.email,
          photo: account&.photo,
          fullname: account&.full_name,
          position_name: account&.position_name,
          departments_chain: account&.departments_chain
      }
    end
  end

end
