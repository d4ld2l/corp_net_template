class ResumeFileCreatorWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high', retry: true


  def perform(candidate_id)
    candidate = Candidate.find_by_id(candidate_id)
    return if candidate.blank?
    file_path = ResumeDocuments::ResumeCreator.new(resource: candidate).build_resume
    candidate.update_resume_file(file_path)
    Pathname.new(file_path).unlink
  end
end
