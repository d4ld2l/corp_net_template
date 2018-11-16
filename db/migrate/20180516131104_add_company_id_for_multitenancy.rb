class AddCompanyIdForMultitenancy < ActiveRecord::Migration[5.0]
  def change
    add_reference :vacancies, :company, index: true
    add_reference :candidates, :company, index: true
    add_reference :projects, :company, index: true
    add_reference :profiles, :company, index: true
    add_reference :positions, :company, index: true
    add_reference :position_groups, :company, index: true
  end
end
