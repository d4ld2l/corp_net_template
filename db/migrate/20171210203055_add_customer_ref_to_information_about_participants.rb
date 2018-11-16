class AddCustomerRefToInformationAboutParticipants < ActiveRecord::Migration[5.0]
  def change
    add_reference :information_about_participants, :customer, foreign_key: true
  end
end
