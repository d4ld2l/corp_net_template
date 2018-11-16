class AddCompanyIdToPosts < ActiveRecord::Migration[5.2]
  def change
    add_column :posts, :company_id, :bigint, index: true
  end
end
