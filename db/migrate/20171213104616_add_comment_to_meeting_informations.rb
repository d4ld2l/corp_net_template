class AddCommentToMeetingInformations < ActiveRecord::Migration[5.0]
  def change
    add_column :meeting_informations, :comment, :text
  end
end
