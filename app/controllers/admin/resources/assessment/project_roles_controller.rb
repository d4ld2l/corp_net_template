module Admin
  module Resources
    module Assessment
      class ProjectRolesController < Admin::ResourceController
        include Paginatable
        before_action :set_skills_collection

        private

        def set_skills_collection
          @skills ||= Skill.all.joins(:indicators).order(:name).where(company_id:current_tenant&.id).distinct
        end

        def chain_collection_inclusion
          [:skills]
        end

        def permitted_attributes
          [:name, :description, skill_ids:[], project_role_skills_attributes:[:id, :skill_id, :_destroy]]
        end

        def resource_class
          'Assessment::ProjectRole'.constantize
        end

        def resource_collection
          'Assessment::ProjectRole'.constantize
        end

        def collection_name
          'project_roles'
        end
      end
    end
  end
end
