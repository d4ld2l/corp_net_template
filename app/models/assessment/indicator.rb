module Assessment
  class Indicator < ApplicationRecord
    belongs_to :skill

    acts_as_tenant :company

    validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :skill_id }

    counter_culture :skill, column_name: 'indicators_count'
  end
end
