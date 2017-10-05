class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :file
      t.integer :document_attachable_id
      t.string :document_attachable_type

      t.timestamps
    end
  end
end
