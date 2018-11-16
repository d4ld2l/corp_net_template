class Admin::Resources::CandidatesController < Admin::ResourceController
  include Paginatable

  def info360
    @candidate = Candidate.find params[:id]
  end
end
