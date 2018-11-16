# Информация об участниках встречи
class InformationAboutParticipant < ApplicationRecord
  belongs_to :representation_allowance
  belongs_to :project
  belongs_to :customer
  has_many :participants, -> { where(type_of_participant: :belong_to_company) }, dependent: :destroy, class_name: 'Participant'
  has_one :responsible_participant, ->{ where(type_of_participant: :belong_to_company).where(responsible:true) }, dependent: :destroy, class_name: 'Participant'
  has_many :non_responsible_participants, -> { where(type_of_participant: :belong_to_company).where(responsible: false) }, dependent: :destroy, class_name: 'Participant'
  has_many :other_participants, class_name: 'CounterpartiesInformationAboutParticipant', dependent: :destroy
  has_many :not_responsible_other_participants, class_name: 'CounterpartiesInformationAboutParticipant', dependent: :destroy
  has_many :counterparties, through: :other_participants, class_name: 'Counterparty'
  has_many :not_responsible_counterparties, -> { where(responsible: false) }, through: :not_responsible_other_participants,
           class_name: 'Counterparty', source: :counterparty

  accepts_nested_attributes_for :participants, reject_if: proc { |x| [x[:id], x[:user_id], x[:name], x[:position]].all?(&:blank?) }, allow_destroy: true
  accepts_nested_attributes_for :customer
  accepts_nested_attributes_for :other_participants, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :counterparties, reject_if: :all_blank, allow_destroy: true

  validates :project_id, presence: true

  def build_other_participants_by_customer(customer)
    customer.counterparties.map do |c|
      x = CounterpartiesInformationAboutParticipant.new(counterparty: c, information_about_participant_id: id)
      x.yield_self(&:save)
    end
  end

  # TODO: find for usages and destroy
  def responsible_counterparty
    self.counterparties.where(responsible: true)&.first
  end

  def participants_for_docx
    participants.where(responsible: false).map do |p|
      "#{p.account&.full_name} (#{p.account&.position_name})"
    end.join("; ")
  end

  def counterparties_for_docx
    not_responsible_counterparties.where(responsible: false).map do |c|
      "#{c.name} (#{c.position})"
    end.join("; ")
  end

  protected

  def only_one_responsible_counterparty
    matches = self.counterparties.to_a.select(&:responsible?)
    if matches.count > 1
      errors.add(:default, 'Только один контрагент может быть ответственным')
    end
  end
end
