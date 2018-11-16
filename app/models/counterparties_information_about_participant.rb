# Связка иныф об учатсниках встречи с контрагентами заказчика
class CounterpartiesInformationAboutParticipant < ApplicationRecord
  belongs_to :counterparty
  belongs_to :information_about_participant

  accepts_nested_attributes_for :counterparty
  accepts_nested_attributes_for :information_about_participant
end
