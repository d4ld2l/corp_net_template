class Achievement < ApplicationRecord
  has_many :account_achievements, dependent: :destroy
  belongs_to :achievement_group, optional: true

  mount_uploader :photo, ResumeFileUploader

  validates_presence_of :name, :code

  def grant(account_id)
    transaction do
      return unless self.enabled?
      aa = AccountAchievement.find_or_initialize_by(account_id: account_id, achievement_id: id)
      return if aa.persisted? && !can_achieve_again?
      aa.save
      Transaction.create(
          recipient_id: account_id,
          account_achievement_id: aa.id,
          kind: :refill,
          value: pay
      )
      self
    end
  end

  def toggle
    update(enabled: !enabled)
  end
end
