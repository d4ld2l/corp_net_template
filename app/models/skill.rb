class Skill < ApplicationRecord
  include Elasticsearch::Model
  include Indexable

  has_many :resume_skills
  has_many :account_skills, dependent: :destroy
  has_many :accounts, through: :account_skills
  has_many :indicators, class_name: 'Assessment::Indicator', dependent: :destroy
  has_many :project_roles_skills, class_name: 'Assessment::ProjectRoleSkill', dependent: :destroy
  has_many :project_roles, class_name: 'Assessment::ProjectRole', through: :project_roles_skills
  has_many :session_skills, class_name:'Assessment::SessionSkill', foreign_key: :skill_id, dependent: :destroy

  accepts_nested_attributes_for :indicators, reject_if: :all_blank, allow_destroy: true

  validate :indicators_must_have_different_names
  validates_presence_of :name
  validates :name, uniqueness: { case_sensitive: false, scope: [ :company_id ] }

  acts_as_tenant :company

  def self.search(query, options={})
    __elasticsearch__.search(
        query: {
            bool: {
                must: {
                    multi_match: {
                        query: query,
                        type: 'phrase_prefix',
                        fields: %w[name]
                    }
                }
            }
        },
        sort: [{ _score: { order: :desc } },
               { created_at: { order: :desc } }]
    )
  end

  private

  def indicators_must_have_different_names
    inds = indicators.to_a - indicators.uniq(&:name)
    if inds.size > 0
      errors.add(:indicator_ids, 'Индикаторы должны быть уникальны') # Workaround
      inds.each{|x| x.errors.add(:name, 'Индикаторы должны быть уникальны')}
    end
  end
end
