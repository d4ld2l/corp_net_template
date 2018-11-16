class AddCompanyIdToSomeEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :news_categories, :company_id, :bigint, index: true
    add_column :news_items, :company_id, :bigint, index: true
    add_column :surveys, :company_id, :bigint, index: true
    add_column :survey_results, :company_id, :bigint, index: true
    add_column :services, :company_id, :bigint, index: true
    add_column :service_groups, :company_id, :bigint, index: true
    add_column :bids, :company_id, :bigint, index: true
    add_column :bid_stages_groups, :company_id, :bigint, index: true
    add_column :bid_stages, :company_id, :bigint, index: true
  end
end
