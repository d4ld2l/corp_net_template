class CreateCounterpartiesInformationsAboutParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :counterparties_information_about_participants do |t|
      t.belongs_to :counterparty, foreign_key: true, index: { name: :index_cntprts_info_about_participants_on_cntrprt_id }
      t.belongs_to :information_about_participant, foreign_key: true, index: { name: :index_cntrprts_iap_on_iap_id }
    end
  end
end
