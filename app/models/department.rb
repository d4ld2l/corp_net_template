class Department < ApplicationRecord
  include Departments::CsvExportable
  include Elasticsearch::Model
  include Indexable

  acts_as_tenant :company

  belongs_to :company
  belongs_to :parent, class_name: 'Department', foreign_key: :parent_id, optional: true, required: false
  belongs_to :legal_unit
  belongs_to :manager, class_name: 'Account', foreign_key: :manager_id, required: false

  has_many :legal_unit_employee_positions, foreign_key: :department_code, primary_key: :code
  has_many :legal_unit_employees, through: :legal_unit_employee_positions
  has_many :accounts, -> {distinct}, through: :legal_unit_employees
  has_many :children, class_name: 'Department', foreign_key: :parent_id

  has_one :mailing_list, as: :importable, dependent: :destroy

  scope :top_level, -> { where(parent_id: nil) }
  scope :with_children, -> { includes(:children) }
  scope :with_employees, -> { includes(legal_unit_employee_positions: [legal_unit_employee: [:account]]) }

  scope :search_import, -> { with_children.with_employees }

  alias_attribute :name, :name_ru

  def as_indexed_json(options = {})
    as_json(only: %i[code], methods: :name)
  end

  def self.search(query, options={})
    __elasticsearch__.search(
        query: {
            bool: {
                must: {
                    multi_match: {
                        query: query,
                        type: 'phrase_prefix',
                        fields: %w[name code]
                    }
                }
            }
        }
    )
  end

  def to_mailing_list(account)
    self.mailing_list ||= build_mailing_list(name: parents.map(&:name_ru).push(name_ru).join(' - '), creator: account)
    ml = self.mailing_list
    ml.update_attribute(:name, parents.map(&:name_ru).push(name_ru).join(' - '))
    ml.accounts = deep_employees
    ml
  end

  mount_uploader :logo, DepartmentsPhotoUploader

  validates :name_ru, :code, presence: true
  validates_uniqueness_of :code, scope: [:legal_unit_id]

  def employees
    Account.joins(all_legal_unit_employees: [{ legal_unit_employee_position: :department }]).where("departments.id = #{id}").distinct
  end

  def employees_count
    employees.count
  end

  def deep_employees
    id = self.id
    sql = "WITH RECURSIVE deep_departments(department_id) AS (
               SELECT d.id AS department_id
               FROM departments AS d
               WHERE d.id = #{id}
               UNION
               SELECT d.id AS department_id
               FROM departments AS d
               INNER JOIN deep_departments AS de ON d.parent_id = de.department_id
               WHERE d.id = #{id}
             )
             SELECT DISTINCT accounts.*
             FROM accounts INNER JOIN legal_unit_employees ON legal_unit_employees.account_id = accounts.id INNER JOIN legal_unit_employee_positions ON legal_unit_employee_positions.legal_unit_employee_id = legal_unit_employees.id INNER JOIN departments ON departments.code = legal_unit_employee_positions.department_code
             WHERE departments.id IN (SELECT * FROM deep_departments)"
    ids = Account.find_by_sql(sql).map(&:id)
    Account.where(id: ids)
  end

  def deep_children
    id = self.id
    sql = "WITH RECURSIVE deep_departments(department_id) AS (
               SELECT d.id AS department_id, d.code, d.parent_id
               FROM departments AS d
               WHERE d.id = #{id}
               UNION ALL
               SELECT d.id AS department_id, d.code, d.parent_id
               FROM departments AS d
               INNER JOIN deep_departments AS dd ON d.parent_id = dd.department_id
             ) SELECT department_id as id, code FROM deep_departments"
    self.class.find_by_sql(sql)
  end

  def parents(x = [])
    if parent.blank? || x.include?(parent.parent)
      x
    else
      arr = [parent] + x
      parent.parents(arr)
    end
  end

  def parents_sql
    sql = "WITH RECURSIVE department_children(department_id) AS(
          SELECT d.id AS department_id, d.code, d.parent_id
               FROM departments AS d
               WHERE d.id = #{parent.id}
               UNION
               SELECT d.id AS department_id, d.code, d.parent_id
               FROM departments AS d
               INNER JOIN department_children AS dd ON dd.parent_id = d.id
             ) SELECT department_id as id, code FROM department_children"
    self.class.find_by_sql(sql)
  end

  def block_and_practice_string
    parent ? [parent.name_ru, name_ru].join(' / ') : name_ru
  end
end
