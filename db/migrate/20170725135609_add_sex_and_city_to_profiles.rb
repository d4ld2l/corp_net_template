class AddSexAndCityToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :sex, :integer
    add_column :profiles, :city, :string
  end
end
