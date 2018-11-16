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
      AccountProject.where(account_id: manager.id, project_id: project.id, project_role_id: ProjectRole.find_by_name('Руководитель')).exists? && projects.includes?(project)
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
      default_legal_unit_employee&.departments_chain
    end

    def subordinates_count
      subordinates.count
    end

    def subordinates
      Account.includes(:default_legal_unit_employee).where(legal_unit_employees: {manager_id: id})
    end

    def subordinates_deep
      sql = "WITH RECURSIVE subordinates_deep(account_id) AS (
               SELECT a.id AS account_id
               FROM accounts AS a INNER JOIN legal_unit_employees AS l ON l.account_id = a.id
               WHERE l.default = TRUE AND l.manager_id = #{id}
               UNION
               SELECT a.id AS account_id
               FROM accounts AS a INNER JOIN legal_unit_employees AS l ON l.account_id = a.id
                 INNER JOIN subordinates_deep AS s ON l.manager_id = s.account_id
               WHERE l.legal_unit_id = #{default_legal_unit_employee&.legal_unit&.id}
             )
             SELECT accounts.*
             FROM accounts
             WHERE accounts.id IN (SELECT * FROM subordinates_deep)"
      ids = Account.find_by_sql(sql).map(&:id)
      Account.includes(:default_legal_unit_employee).where(id: ids)
    end

    def subordinates_deep_count
      subordinates_deep.count
    end
  end
end