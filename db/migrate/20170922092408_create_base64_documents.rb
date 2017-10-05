class CreateBase64Documents < ActiveRecord::Migration[5.0]
  def change
    create_table :base64_documents do |t|
      t.string :file
      t.string :name
      t.references :base64_doc_attachable, polymorphic: true, index: {name: 'index_base64_documents_on_base64_doc_attachable'}

      t.timestamps
    end
  end
end
