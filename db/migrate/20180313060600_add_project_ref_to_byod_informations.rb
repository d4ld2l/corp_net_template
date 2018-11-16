class AddProjectRefToByodInformations < ActiveRecord::Migration[5.0]
  def change
    add_column :byod_informations, :project_id, :integer, index: true
  end
end
