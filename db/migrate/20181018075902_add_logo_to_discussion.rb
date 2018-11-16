class AddLogoToDiscussion < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :logo, :string
  end
end
