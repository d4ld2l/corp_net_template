class SurveyUnpublishWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default', retry: true

  def perform(survey_id)
    survey = Survey.find(survey_id)
    if survey && (survey.ends_at < DateTime.now+12.hours) && survey.published?
      survey.to_unpublished
      survey.unpublished_at = DateTime.now
      survey.save(validate: false)
      PersonalNotificationsWorker.perform_async(profile_id: survey.creator&.profile&.id, action_type: :your_survey_unpublished, issuer_json: survey.to_issuer_json)
    end
  end
end
