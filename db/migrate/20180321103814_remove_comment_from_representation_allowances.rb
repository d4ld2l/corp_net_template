class RemoveCommentFromRepresentationAllowances < ActiveRecord::Migration[5.0]
  def change
    remove_column :meeting_informations, :comment, :string
  end
end
