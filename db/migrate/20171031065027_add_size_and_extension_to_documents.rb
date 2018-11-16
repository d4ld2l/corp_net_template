class AddSizeAndExtensionToDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :size, :integer, default:0, null:false
    add_column :documents, :extension, :string
  end
end
