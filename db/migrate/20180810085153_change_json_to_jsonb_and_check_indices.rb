class ChangeJsonToJsonbAndCheckIndices < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :allowed_bid_stages, :notifiable, 'jsonb USING CAST(notifiable AS jsonb)'
        change_column :contact_messengers, :phones, 'jsonb USING CAST(phones AS jsonb)'
        change_column :customer_contacts, :social_urls, 'jsonb USING CAST(social_urls AS jsonb)'
        change_column :personal_notifications, :parent, 'jsonb USING CAST(parent AS jsonb)'
        change_column :profile_messengers, :phones, 'jsonb USING CAST(phones AS jsonb)'
        change_column :resumes, :employment_type, 'jsonb USING CAST(employment_type AS jsonb)'
        change_column :resumes, :working_schedule, 'jsonb USING CAST(working_schedule AS jsonb)'
        change_column :resumes, :documents, 'jsonb USING CAST(documents AS jsonb)'
        change_column :resumes, :experience, 'jsonb USING CAST(experience AS jsonb)'
        change_column :vacancies, :experience, 'jsonb USING CAST(experience AS jsonb)'
        change_column :vacancies, :schedule, 'jsonb USING CAST(schedule AS jsonb)'
        change_column :vacancies, :type_of_employment, 'jsonb USING CAST(type_of_employment AS jsonb)'
      end
      dir.down do
        change_column :allowed_bid_stages, :notifiable, 'json USING CAST(notifiable AS json)'
        change_column :contact_messengers, :phones, 'json USING CAST(phones AS json)'
        change_column :customer_contacts, :social_urls, 'json USING CAST(social_urls AS json)'
        change_column :personal_notifications, :parent, 'json USING CAST(parent AS json)'
        change_column :profile_messengers, :phones, 'json USING CAST(phones AS json)'
        change_column :resumes, :employment_type, 'json USING CAST(employment_type AS json)'
        change_column :resumes, :working_schedule, 'json USING CAST(working_schedule AS json)'
        change_column :resumes, :documents, 'json USING CAST(documents AS json)'
        change_column :resumes, :experience, 'json USING CAST(experience AS json)'
        change_column :vacancies, :experience, 'json USING CAST(experience AS json)'
        change_column :vacancies, :schedule, 'json USING CAST(schedule AS json)'
        change_column :vacancies, :type_of_employment, 'json USING CAST(type_of_employment AS json)'
      end
    end
    add_index :achievements, :achievement_group_id
    add_index :byod_informations, :project_id
    add_index :comments, :account_id
    add_index :confirm_skills, :account_id
    add_index :confirm_skills, :resume_skill_id
    add_index :departments, :manager_id
    add_index :documents, :uploaded_by_id
    add_index :events, :created_by_id
    add_index :legal_unit_employees, :manager_id
    add_index :mailing_lists, :account_id
    add_index :news_items, :community_id
    add_index :projects, :manager_id
    add_index :resume_certificates, :resume_id
    add_index :resume_skills, %i[resume_id skill_id]
    add_index :skills, :account_id
    add_index :skills, :project_id
    add_index :vacancies, :owner_id
    add_index :vacancies, :creator_id
    add_index :vacancy_stages, :vacancy_stage_group_id
  end
end
