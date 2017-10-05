class Admin::Resources::ResumesController < Admin::ResourceController
  before_action :set_resume_skills, only: [:new, :edit]
  before_action :set_user, only: :new
  include Paginatable

  private

  def permitted_attributes
    [:user_id, :position, :desired_position, :salary_level, :skill_list,
     :skills_description, :comment, :professional_specialization_id,
     professional_specializations_resumes_attributes: [:professional_specialization_id],
     resume_work_experiences_attributes:
         [:id, :_destroy, :position, :company_name, :region, :website, :start_date, :end_date, :experience_description],
     resume_recommendations_attributes:[:id, :recommender_name, :company_and_position, :phone, :email, :_destroy],
     resume_certificates_attributes:[:id, :name, :company_name, :start_date, :_destroy]
    ]
  end

  def association_chain
    super.only_my(current_user.id)
  end

  def set_user
    @resource_instance.user_id = params[:user_id]
  end

  def set_resume_skills
    @resume_skills_collection = Skill.all
  end
end
