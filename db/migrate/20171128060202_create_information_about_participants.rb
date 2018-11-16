class CreateInformationAboutParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :information_about_participants do |t|
      t.references :representation_allowance, foreign_key: { on_delete: :cascade },
                   index: { name: 'index_inf_ab_participants_on_repr_allowance_id' }
      t.string :organization_name
      t.references :project, foreign_key: { on_delete: :nullify }

      t.timestamps
    end
  end
end
