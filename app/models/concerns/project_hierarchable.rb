module ProjectHierarchable
  extend ActiveSupport::Concern

  included do
    def is_managed_by?(manager)
      x = self
      res = false
      while x.default_legal_unit_employee&.manager
        if x.default_legal_unit_employee&.manager_id == manager.id
          res = true
          break
        end
        x = x.default_legal_unit_employee&.manager
      end
      res
    end

    def is_managed_by_on_project?(manager, project)
      UserProject.find_by(user_id: manager.user.id, project_id: project.id, project_role_id: ProjectRole.find_by_name('Руководитель')).present?&& self.user.projects.includes?(project)
    end

    def managed_projects
      Project.includes(:user_projects).where(user_project: {user_id: manager.user.id, project_id: project.id, project_role_id: ProjectRole.find_by_name('Руководитель')})
    end

    def subordination_chain
      chain = []
      x = self
      while x.default_legal_unit_employee&.manager
        chain << x.default_legal_unit_employee&.manager&.id
        x = x.default_legal_unit_employee&.manager
        break if chain.size > 5
      end
      chain
    end

    def departments_chain
      chain = []
      x = self.default_legal_unit_employee&.legal_unit_employee_position&.department
      while x
        chain << x
        x = x&.parent
        break if chain.size > 5
      end
      chain.reverse
    end

    def subordinates_count
      subordinates.count
    end

    def subordinates
      Profile.includes(:default_legal_unit_employee).where(legal_unit_employees: {manager_id: self.id})
    end

    def subordinates_deep
      sql = "WITH RECURSIVE subordinates_deep(profile_id) AS (
               SELECT p.id AS profile_id
               FROM profiles AS p INNER JOIN legal_unit_employees AS l ON l.profile_id = p.id
               WHERE l.default = TRUE AND l.manager_id = #{self.id}
               UNION
               SELECT p.id AS profile_id
               FROM profiles AS p INNER JOIN legal_unit_employees AS l ON l.profile_id = p.id
                 INNER JOIN subordinates_deep AS s ON l.manager_id = s.profile_id
               WHERE l.legal_unit_id = #{self.default_legal_unit_employee&.legal_unit&.id}
             )
             SELECT profiles.*
             FROM profiles
             WHERE profiles.id IN (SELECT * FROM subordinates_deep)"
      ids = Profile.find_by_sql(sql).map(&:id)
      Profile.includes(:default_legal_unit_employee).where(id: ids)
    end

    def subordinates_deep_count
      subordinates_deep.count
    end
  end
end