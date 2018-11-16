class SurveyGoingToUnpublishedNotifierWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'notifications', retry: true

  def perform(survey_id)
    survey = Survey.find_by(id: survey_id)
    return unless survey.present?
    passed = SurveyResult.where(survey_id: survey_id).pluck(:user_id)
    ids = survey.available_to_all? ? Profile.not_blocked.ids - passed : survey.survey_participants.joins(:user => :profile).pluck('profiles.id') - passed
    PersonalNotificationsWorker.perform_async(profile_id: ids, action_type: :survey_going_to_unpublish, issuer_json: survey.to_issuer_json, initiator_id: RequestStore[:current_user]&.profile&.id) if ids.any?
  end
end
