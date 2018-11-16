class ChangeUserToAccountInSurveys < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :surveys, column: :creator_id
    remove_foreign_key :surveys, column: :editor_id
    remove_foreign_key :surveys, column: :publisher_id
    remove_foreign_key :surveys, column: :unpublisher_id
  end
end
