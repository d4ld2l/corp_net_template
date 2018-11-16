class Api::V0::CandidateRatingsController < Api::BaseController
  before_action :authenticate_account!

  def create
    @candidate_rating = CandidateRating.new(candidate_rating_params)
    if @candidate_rating.save
      render json: {success: true, data: @candidate_rating.as_json}
    else
      render json: {success: false, errors: @candidate_rating.errors.as_json}
    end
  end

  private

  def candidate_rating_params
    params.require(:candidate_rating).permit(:rating_type, :value, :vacancy_stage_id, :candidate_vacancy_id, :commenter_id)
  end
end
