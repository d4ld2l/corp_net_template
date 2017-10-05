class Admin::Resources::ResumeSkillsController < Admin::BaseController
  include Paginatable

  def index
  end

  def show
  end

  def new
    @resume_id = params[:id]
    @skill = ResumeSkill.new
  end

  def edit
  end

  def update
  end

  def create
    #@skill = ResumeSkill.new(resume_skill_params)
    resume_skills = resume_skill_params[:skill_id].reject {|s| s.empty?}
    resume_skill_params[:skill_id].each do |id|
      @skill = ResumeSkill.new
      @skill.resume_id = resume_skill_params[:resume_id]
      @skill.skill_id = id
      @skill.save
    end

    redirect_to resumes_path, notice: "Навык успешно добавлен"
  end


  private

  def resume_skill_params
    params.require(:resume_skill).permit(:resume_id, :skill_id => [])
  end
end
