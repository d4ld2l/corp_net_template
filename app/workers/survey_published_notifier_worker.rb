class SurveyPublishedNotifierWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'notifications', retry: true

  def perform(survey_id)
    survey = Survey.find_by(id: survey_id)
    return unless survey.present?
    ids = survey.available_to_all? ? Profile.not_blocked.ids : survey.survey_participants.joins(:user => :profile).pluck('profiles.id')
    PersonalNotificationsWorker.perform_async(profile_id: ids, action_type: :survey_published, issuer_json: survey.to_issuer_json, initiator_id: RequestStore[:current_user]&.profile&.id) if ids.any?
  end
end
