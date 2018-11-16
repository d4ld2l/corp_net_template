class AddImageToOfferedVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :offered_variants, :image, :string
  end
end
