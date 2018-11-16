class CreateContactPhones < ActiveRecord::Migration[5.0]
  def change
    create_table :contact_phones do |t|
      t.integer :kind, default: 0
      t.references :contactable, polymorphic: true, index: true
      t.string :number
      t.boolean :preferable,     default:false
      t.boolean :whatsapp,       default:false
      t.boolean :telegram,       default:false
      t.boolean :vider,          default:false

      t.timestamps
    end
  end
end
