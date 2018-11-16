class Api::V0::SimilarCandidatesController < Api::BaseController
  before_action :authenticate_account!

  def save_both
    @pair = SimilarCandidatesPair.find_pair(params[:first_id], params[:second_id])
    if @pair.blank?
      render json: {status: 'error'}
    else
      @pair.save_both!
      render json: {status: 'success'}
    end
  end

  def save_one
    @pair = SimilarCandidatesPair.find_pair(params[:first_id], params[:second_id])
    if @pair.blank?
      render json: {status: 'error'}
    else
      begin
        @pair.save_candidate_by_id(params[:save_id])
      rescue
        render json: {status: 'error'}
      else
        render json: {status: 'success'}
      end
    end
  end
end
