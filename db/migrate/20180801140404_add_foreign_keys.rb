class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :transactions, :account_achievements
    add_foreign_key :personal_notifications, :accounts
    add_foreign_key :bids_executors, :accounts
    add_foreign_key :bids, :accounts, column: :assistant_id
    add_foreign_key :bids, :accounts, column: :author_id
    add_foreign_key :bids, :accounts, column: :manager_id
    add_foreign_key :bids, :accounts, column: :matching_user_id
    add_foreign_key :bids, :accounts, column: :creator_id
    add_foreign_key :candidate_changes, :accounts
    add_foreign_key :candidate_ratings, :accounts, column: :commenter_id
    add_foreign_key :comments, :accounts
    add_foreign_key :communities, :accounts
    add_foreign_key :confirm_skills, :accounts
    add_foreign_key :contacts_services, :accounts, column: :contact_id
    add_foreign_key :discussers, :accounts
    add_foreign_key :event_participants, :accounts
    add_foreign_key :favorite_discussions, :accounts
    add_foreign_key :favorite_posts, :accounts
    add_foreign_key :legal_units, :accounts, column: :assistant_id
    add_foreign_key :legal_unit_employees, :accounts
    add_foreign_key :legal_unit_employees, :accounts, column: :manager_id
    add_foreign_key :likes, :accounts
    add_foreign_key :mailing_lists, :accounts
    add_foreign_key :mentions, :accounts
    add_foreign_key :messages, :accounts
    add_foreign_key :news_items, :accounts
    add_foreign_key :notifications, :accounts
    add_foreign_key :participants, :accounts
    add_foreign_key :posts, :accounts, column: :author_id
    add_foreign_key :posts, :accounts, column: :deleted_by_id
    add_foreign_key :project_work_periods, :account_projects
    add_foreign_key :projects, :accounts, column: :manager_id
    add_foreign_key :projects, :accounts, column: :created_by_id
    add_foreign_key :projects, :accounts, column: :updated_by_id
    add_foreign_key :surveys, :accounts, column: :creator_id
    add_foreign_key :surveys, :accounts, column: :editor_id
    add_foreign_key :surveys, :accounts, column: :publisher_id
    add_foreign_key :surveys, :accounts, column: :unpublisher_id
    add_foreign_key :survey_participants, :accounts
    add_foreign_key :survey_results, :accounts
    add_foreign_key :task_observers, :accounts

  end
end
