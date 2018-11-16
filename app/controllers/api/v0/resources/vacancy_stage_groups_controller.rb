class Api::V0::Resources::VacancyStageGroupsController < Api::ResourceController
  skip_before_action :set_collection, only: :index

  def stats
    hash = VacancyStageGroup.candidates_count
    res = []
    VacancyStageGroup.all.each do |vsg|
      cvc = hash.fetch(vsg.id, 0)
      res << vsg.as_json.merge({candidates_count: cvc})
    end
    render json:
               {
                   total_candidates_count: Candidate.count,
                   unassigned_candidates_count: Candidate.unassigned.count,
                   vacancy_stage_groups: res
               }
  end

  def recruitment_vortex
    if params[:start_date].blank?
      render json: {success: false, error: 'Отсутствует дата начала'}
    else
      begin
        hash = CandidateChange.vacancy_stage_groups_vortex(params[:start_date], params[:end_date] || DateTime.current)
        res = []
        VacancyStageGroup.all.each do |vsg|
          cvc = hash.fetch(vsg.id, 0)
          res << vsg.as_json.merge({candidates_vortex_count: cvc})
        end
        render json: res.as_json
      rescue StandardError => e
        render json: {success: false, error: e.message}
      end
    end
  end
end
