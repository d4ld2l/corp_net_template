class AddPublisherToDocument < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :uploaded_by_id, :integer, foreign_key: true
  end
end
