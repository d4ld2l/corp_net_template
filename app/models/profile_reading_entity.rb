class ProfileReadingEntity < ApplicationRecord
  belongs_to :profile
  belongs_to :readable, polymorphic: true

  validates_uniqueness_of :readable_id, scope: %i[readable_type profile_id]
end
