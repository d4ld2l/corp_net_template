class Counterparty < ApplicationRecord
  belongs_to :customer
  has_one :counterparties_information_about_participant, dependent: :destroy

  after_commit :make_the_only_responsible, if: ->{responsible?}

  private

  ## TODO: DELETE IT!!! And move responsible field to CounterpartiesInformationAboutParticipant
  def make_the_only_responsible
    customer.counterparties.where(responsible: true).where.not(id: id).update_all(responsible: false)
  end

end
