module Assessment
  class Spectator < ApplicationRecord
    self.table_name_prefix = 'assessment_'

    belongs_to :assessment_session, class_name: 'Assessment::Session'
    belongs_to :account

    validates :account_id, uniqueness: { scope: :assessment_session_id }, presence: true
  end
end
