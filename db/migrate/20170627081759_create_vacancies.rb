class CreateVacancies < ActiveRecord::Migration[5.0]
  def change
    create_table :vacancies do |t|
      t.string :status
      #manager
      #first step
      t.string :name
      t.integer :positions_count
      t.text :demands
      t.text :duties
      t.json :experience
      t.json :schedule
      t.json :type_of_employment
      t.integer :type_of_salary
      t.integer :level_of_salary_from
      t.integer :level_of_salary_to
      t.boolean :show_salary
      t.integer :type_of_contract
      t.string :place_of_work
      t.text :comment

      #second step
      t.belongs_to :user
      t.date :ends_at
      t.text :job_subdivision
      #company -> employee
      t.text :comment_for_employee
      t.text :additional_tests
      t.string :file
      t.text :reason_for_opening
      #recruiter

      t.timestamps
    end
  end
end
