class ChangeKindFromStringToIntegerInProfileEmail < ActiveRecord::Migration[5.0]
  def up
    remove_column :profile_emails, :kind
    add_column :profile_emails, :kind, :integer
  end

  def down
    remove_column :profile_emails, :kind
    add_column :profile_emails, :kind, :string
  end
end
