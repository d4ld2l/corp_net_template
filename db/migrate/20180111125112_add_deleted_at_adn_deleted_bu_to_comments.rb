class AddDeletedAtAdnDeletedBuToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :deleted_at, :datetime
    add_column :comments, :deleted_by_id, :integer, index: true
  end
end
