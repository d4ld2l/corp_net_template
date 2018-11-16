class AddImportableToMailingList < ActiveRecord::Migration[5.0]
  def change
    add_column :mailing_lists, :importable_type, :string
    add_column :mailing_lists, :importable_id, :integer
    add_index :mailing_lists, [:importable_id, :importable_type]
  end
end
