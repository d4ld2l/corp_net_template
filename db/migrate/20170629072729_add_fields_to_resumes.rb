class AddFieldsToResumes < ActiveRecord::Migration[5.0]
  def change
    add_column :resumes, :first_name, :string
    add_column :resumes, :middle_name, :string
    add_column :resumes, :last_name, :string
    add_column :resumes, :position, :string
    add_column :resumes, :city, :string
    add_column :resumes, :phone, :string
    add_column :resumes, :email, :string
    add_column :resumes, :skype, :string
    add_column :resumes, :preferred_contact_type, :integer
    add_column :resumes, :birthdate, :date
    add_column :resumes, :photo, :string
    add_column :resumes, :sex, :integer
    add_column :resumes, :martial_condition, :integer
    add_column :resumes, :have_children, :integer
    add_column :resumes, :skills_description, :text
    add_column :resumes, :desired_position, :string
    add_column :resumes, :salary_level, :integer
    add_column :resumes, :employment_type, :json
    add_column :resumes, :working_schedule, :json
    add_column :resumes, :comment, :text

    add_reference :resumes, :vacancy, index: true
  end
end
