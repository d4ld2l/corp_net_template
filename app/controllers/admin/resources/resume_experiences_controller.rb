class Admin::Resources::ResumeExperiencesController < Admin::BaseController

  def index
      @collection = Resume.all
  end

  def show
      @resume = Resume.find_by_id(params[:id])
      @experiences = Resume.find_by_id(params[:id]).resume_experiences
  end

  def new
      @resume_id = params[:id]
      @resume_exp = ResumeExperience.new
  end

  def edit
      @resume_exp = ResumeExperience.find(params[:id])
  end

  def update
      @resume_exp = ResumeExperience.find(params[:id])
      if @resume_exp.update_attributes(resume_exp_params)
          redirect_to resumes_path, notice: "Место работы обновлено"
      else
          render :edit
      end
  end

  def create
      #raise resume_params[:resume_skills].to_s
      @resume_exp = ResumeExperience.new(resume_exp_params)
      if @resume_exp.save
          redirect_to resumes_path, notice: "Место работы успешно создано"
      else
          render :new
      end
  end

  private

  def resume_exp_params
    params.require(:resume_experience).permit(:resume_id, :company_id, :position, :start_date, :end_date, :tasks)
  end
end
