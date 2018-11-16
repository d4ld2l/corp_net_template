class Admin::Resources::ProfileProjectsController < Admin::BaseController
    def index
        #@resumes = Resume.all
    end

    def show
        #@resume = Resume.find_by_id(params[:id])
        #@experiences = Resume.find_by_id(params[:id]).resume_experiences
    end

    def new
        @project_id = params[:id]
        @resource_instance= ProfileProject.new
    end

    def edit
        #@resume_exp = ResumeExperience.find(params[:id])
    end

    def update
        #@resume_exp = ResumeExperience.find(params[:id])
        #if @resume_exp.update_attributes(resume_exp_params)
        #    redirect_to resumes_path, notice: "Место работы обновлено"
        #else
        #    render :edit
        #end
    end

    def create
        #raise resume_params[:resume_skills].to_s
        @profile_project = ProfileProject.new(profile_project_params)
        if @profile_project.save
            redirect_to projects_path, notice: "Сотрудник привязан" 
        else
            render :new
        end
    end






private

def profile_project_params
  params.require(:profile_project).permit(:profile_id, :project_id)
end
end
