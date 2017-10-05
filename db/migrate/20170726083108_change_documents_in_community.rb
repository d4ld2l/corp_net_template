class ChangeDocumentsInCommunity < ActiveRecord::Migration[5.0]
  def change
    remove_column :communities, :documents, :json

    add_column :communities, :documents, :string, array: true, default: []
  end
end
