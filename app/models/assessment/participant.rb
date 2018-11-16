module Assessment
  class Participant < ApplicationRecord
    self.table_name_prefix = 'assessment_'

    belongs_to :account
    belongs_to :session, class_name: 'Assessment::Session', foreign_key: :assessment_session_id

    enum kind: [:manager, :subordinate, :associate]

    counter_culture :session,
                    column_name: 'participants_count'

    validates_uniqueness_of :account_id, scope: [ :assessment_session_id ]
  end
end
