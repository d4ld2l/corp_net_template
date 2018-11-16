class Api::V0::CandidateVacancyCommentsController < Api::BaseController
  before_action :authenticate_account!

  def create
    @comment = CandidateVacancy.find(params[:id]).comments.build(comment_params)
    if @comment.save
      render json: {success: true, data: @comment.as_json(json_resource_inclusion)}
    else
      render json: {success: false, errors: @comment.errors.as_json}
    end
  end

  def index
    @comments = CandidateVacancy.includes(comments: :account).find(params[:id]).comments
    render json: @comments.as_json(json_resource_inclusion)
  end

  def destroy
    @comment = CandidateVacancy.find(params[:id]).comments.find(params[:comment_id])
    if @comment.destroy
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def json_resource_inclusion
    {
      include: {
        account: {
          only: %i[id photo],
          methods: :name_surname
        }
      }
    }
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :account_id)
  end
end
