class CandidateComparerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'high', retry: true


  def perform(candidate_id)
    Candidate.find_by_id(candidate_id)&.compare_with_other_candidates
  end
end
