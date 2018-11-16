# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_11_15_133322) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_achievements", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "achievement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_achievements_on_account_id"
    t.index ["achievement_id"], name: "index_account_achievements_on_achievement_id"
  end

  create_table "account_communities", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "community_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_communities_on_account_id"
    t.index ["community_id"], name: "index_account_communities_on_community_id"
  end

  create_table "account_emails", force: :cascade do |t|
    t.string "email"
    t.boolean "preferable"
    t.bigint "account_id"
    t.integer "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_emails_on_account_id"
  end

  create_table "account_mailing_lists", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "mailing_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_mailing_lists_on_account_id"
    t.index ["mailing_list_id"], name: "index_account_mailing_lists_on_mailing_list_id"
  end

  create_table "account_messengers", force: :cascade do |t|
    t.integer "name"
    t.bigint "account_id"
    t.jsonb "phones"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_messengers_on_account_id"
  end

  create_table "account_phones", force: :cascade do |t|
    t.string "number"
    t.boolean "preferable"
    t.bigint "account_id"
    t.integer "kind"
    t.boolean "whatsapp"
    t.boolean "telegram"
    t.boolean "viber"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_phones_on_account_id"
  end

  create_table "account_photos", force: :cascade do |t|
    t.string "photo"
    t.bigint "account_id"
    t.datetime "archived_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cropped_photo"
    t.integer "likes_count", default: 0
    t.jsonb "crop_info"
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_photos_on_account_id"
  end

  create_table "account_profile_users", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "user_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "account_projects", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "project_id"
    t.text "feedback"
    t.integer "rating"
    t.integer "worked_hours"
    t.string "status"
    t.date "gone_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_projects_on_account_id"
    t.index ["project_id"], name: "index_account_projects_on_project_id"
  end

  create_table "account_reading_entities", force: :cascade do |t|
    t.bigint "account_id"
    t.string "readable_type"
    t.bigint "readable_id"
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_reading_entities_on_account_id"
    t.index ["readable_type", "readable_id"], name: "index_account_reading_entities_on_readable_type_and_readable_id"
  end

  create_table "account_roles", force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_roles_on_account_id"
    t.index ["role_id"], name: "index_account_roles_on_role_id"
  end

  create_table "account_skills", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "skill_id"
    t.bigint "project_id"
    t.integer "skill_confirmations_count", default: 0
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_skills_on_account_id"
    t.index ["project_id"], name: "index_account_skills_on_project_id"
    t.index ["skill_id"], name: "index_account_skills_on_skill_id"
  end

  create_table "account_vacancies", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "vacancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_account_vacancies_on_account_id"
    t.index ["vacancy_id"], name: "index_account_vacancies_on_vacancy_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "surname", limit: 100
    t.string "name", limit: 100
    t.string "middlename", limit: 100
    t.string "photo", limit: 200
    t.date "birthday"
    t.string "skype", limit: 100
    t.integer "sex"
    t.string "city"
    t.jsonb "social_urls", default: []
    t.integer "marital_status"
    t.integer "kids", default: 0, null: false
    t.integer "balance", default: 0
    t.integer "updater_id"
    t.string "email", default: "", null: false
    t.integer "company_id"
    t.string "encrypted_password", default: "", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "login"
    t.string "external_id"
    t.string "external_system"
    t.string "status", limit: 15
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.jsonb "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_zone", default: "Moscow", null: false
    t.integer "current_account_photo_id"
    t.index ["company_id", "email"], name: "index_accounts_on_company_id_and_email"
    t.index ["company_id", "login"], name: "index_accounts_on_company_id_and_login"
    t.index ["company_id"], name: "index_accounts_on_company_id"
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
  end

  create_table "achievement_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "achievements", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "photo"
    t.integer "pay", default: 0
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "can_achieve_again", default: false
    t.integer "achievement_group_id"
    t.integer "company_id"
    t.index ["achievement_group_id"], name: "index_achievements_on_achievement_group_id"
  end

  create_table "additional_contacts", id: :serial, force: :cascade do |t|
    t.integer "type"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resume_id"
    t.integer "company_id"
    t.index ["resume_id"], name: "index_additional_contacts_on_resume_id"
  end

  create_table "admin_settings", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "label", default: "", null: false
    t.string "value", default: "", null: false
    t.integer "kind", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "ahoy_events", id: :serial, force: :cascade do |t|
    t.integer "visit_id"
    t.integer "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.integer "company_id"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties_jsonb_path_ops", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", id: :serial, force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.integer "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.string "search_keyword"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.integer "company_id"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "allowed_bid_stages", id: :serial, force: :cascade do |t|
    t.integer "current_stage_id"
    t.integer "allowed_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "additional_executor_id"
    t.boolean "notification"
    t.boolean "to_author", default: false
    t.boolean "to_matching_user", default: false
    t.boolean "to_assistant", default: false
    t.string "name_for_button"
    t.integer "executor"
    t.jsonb "notifiable"
    t.integer "company_id"
    t.index ["additional_executor_id"], name: "index_allowed_bid_stages_on_additional_executor_id"
    t.index ["allowed_stage_id"], name: "index_allowed_bid_stages_on_allowed_stage_id"
    t.index ["current_stage_id"], name: "index_allowed_bid_stages_on_current_stage_id"
  end

  create_table "allowed_bid_stages_bids_executors", id: :serial, force: :cascade do |t|
    t.integer "bids_executor_id"
    t.integer "allowed_bid_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["allowed_bid_stage_id"], name: "index_allowed_bid_stages_bids_executors_on_allowed_bid_stage_id"
    t.index ["bids_executor_id"], name: "index_allowed_bid_stages_bids_executors_on_bids_executor_id"
  end

  create_table "assessment_indicator_evaluations", force: :cascade do |t|
    t.bigint "assessment_skill_evaluation_id"
    t.bigint "indicator_id"
    t.integer "rating_scale", default: 0, null: false
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_skill_evaluation_id"], name: "index_assessment_indicator_evaluations_on_skill_evaluation_id"
    t.index ["indicator_id"], name: "index_assessment_indicator_evaluations_on_indicator_id"
  end

  create_table "assessment_participants", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "assessment_session_id"
    t.integer "kind", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_assessment_participants_on_account_id"
    t.index ["assessment_session_id"], name: "index_assessment_participants_on_assessment_session_id"
    t.index ["kind"], name: "index_assessment_participants_on_kind"
  end

  create_table "assessment_session_evaluations", force: :cascade do |t|
    t.bigint "assessment_session_id"
    t.bigint "account_id"
    t.boolean "done", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_assessment_session_evaluations_on_account_id"
    t.index ["assessment_session_id"], name: "index_assessment_session_evaluations_on_assessment_session_id"
  end

  create_table "assessment_session_skills", force: :cascade do |t|
    t.bigint "assessment_session_id"
    t.bigint "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0
    t.index ["assessment_session_id"], name: "index_assessment_session_skills_on_assessment_session_id"
    t.index ["skill_id"], name: "index_assessment_session_skills_on_skill_id"
  end

  create_table "assessment_sessions", force: :cascade do |t|
    t.string "name"
    t.bigint "account_id"
    t.integer "kind", default: 0, null: false
    t.bigint "project_role_id"
    t.integer "rating_scale", default: 0, null: false
    t.string "status"
    t.text "description"
    t.text "final_step_text"
    t.string "logo"
    t.string "color"
    t.integer "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "skills_count", default: 0, null: false
    t.date "due_date"
    t.integer "company_id"
    t.integer "participants_count", default: 0
    t.integer "evaluations_count", default: 0
    t.string "obvious_fortes"
    t.string "hidden_fortes"
    t.string "growth_direction"
    t.string "blind_spots"
    t.string "conclusion"
    t.index ["account_id"], name: "index_assessment_sessions_on_account_id"
    t.index ["created_by_id"], name: "index_assessment_sessions_on_created_by_id"
    t.index ["project_role_id"], name: "index_assessment_sessions_on_project_role_id"
  end

  create_table "assessment_skill_evaluations", force: :cascade do |t|
    t.bigint "assessment_session_evaluation_id"
    t.bigint "skill_id"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_session_evaluation_id"], name: "index_assessment_skill_evaluations_on_session_evaluations_id"
    t.index ["skill_id"], name: "index_assessment_skill_evaluations_on_skill_id"
  end

  create_table "assessment_spectators", force: :cascade do |t|
    t.bigint "assessment_session_id"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_assessment_spectators_on_account_id"
    t.index ["assessment_session_id"], name: "index_assessment_spectators_on_assessment_session_id"
  end

  create_table "base64_documents", id: :serial, force: :cascade do |t|
    t.string "file"
    t.string "name"
    t.string "base64_doc_attachable_type"
    t.integer "base64_doc_attachable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["base64_doc_attachable_type", "base64_doc_attachable_id"], name: "index_base64_documents_on_base64_doc_attachable"
  end

  create_table "bid_stages", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "bid_stages_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "initial", default: false
    t.bigint "company_id"
    t.index ["bid_stages_group_id"], name: "index_bid_stages_on_bid_stages_group_id"
  end

  create_table "bid_stages_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "initial_executor"
    t.boolean "initial_notification"
    t.jsonb "initial_notifiable"
    t.bigint "company_id"
  end

  create_table "bids", id: :serial, force: :cascade do |t|
    t.integer "service_id"
    t.integer "author_id"
    t.integer "manager_id"
    t.string "manager_position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legal_unit_id"
    t.integer "matching_user_id"
    t.integer "comments_count", default: 0
    t.integer "assistant_id"
    t.integer "creator_id"
    t.string "creator_position"
    t.string "creator_comment"
    t.bigint "company_id"
    t.index ["author_id"], name: "index_bids_on_author_id"
    t.index ["legal_unit_id"], name: "index_bids_on_legal_unit_id"
    t.index ["manager_id"], name: "index_bids_on_manager_id"
    t.index ["matching_user_id"], name: "index_bids_on_matching_user_id"
    t.index ["service_id"], name: "index_bids_on_service_id"
  end

  create_table "bids_bid_stages", id: :serial, force: :cascade do |t|
    t.integer "bid_id"
    t.integer "bid_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["bid_id"], name: "index_bids_bid_stages_on_bid_id"
    t.index ["bid_stage_id"], name: "index_bids_bid_stages_on_bid_stage_id"
  end

  create_table "bids_executors", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_bids_executors_on_account_id"
  end

  create_table "bonus_information_approvers", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "bonus_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_bonus_information_approvers_on_account_id"
    t.index ["bonus_information_id"], name: "index_bonus_information_approvers_on_bonus_information_id"
  end

  create_table "bonus_information_participants", force: :cascade do |t|
    t.bigint "account_id"
    t.decimal "sum", precision: 12, scale: 2
    t.datetime "period_start"
    t.datetime "period_end"
    t.bigint "bonus_information_id"
    t.bigint "legal_unit_id"
    t.string "charge_code", default: "", null: false
    t.text "misc", default: "", null: false
    t.bigint "bonus_reason_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_bonus_information_participants_on_account_id"
    t.index ["bonus_information_id"], name: "index_bonus_information_participants_on_bonus_information_id"
    t.index ["bonus_reason_id"], name: "index_bonus_information_participants_on_bonus_reason_id"
    t.index ["legal_unit_id"], name: "index_bonus_information_participants_on_legal_unit_id"
  end

  create_table "bonus_informations", force: :cascade do |t|
    t.bigint "bid_id"
    t.bigint "bonus_reason_id"
    t.text "additional", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bid_id"], name: "index_bonus_informations_on_bid_id"
    t.index ["bonus_reason_id"], name: "index_bonus_informations_on_bonus_reason_id"
  end

  create_table "bonus_reasons", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "byod_informations", id: :serial, force: :cascade do |t|
    t.integer "bid_id"
    t.integer "byod_type"
    t.string "device_model"
    t.string "device_inventory_number"
    t.float "compensation_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.integer "company_id"
    t.index ["bid_id"], name: "index_byod_informations_on_bid_id"
    t.index ["project_id"], name: "index_byod_informations_on_project_id"
  end

  create_table "candidate_changes", id: :serial, force: :cascade do |t|
    t.integer "change_type"
    t.datetime "timestamp"
    t.integer "account_id"
    t.integer "vacancy_id"
    t.integer "candidate_id"
    t.string "change_for_type"
    t.integer "change_for_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_candidate_changes_on_account_id"
    t.index ["candidate_id"], name: "index_candidate_changes_on_candidate_id"
    t.index ["change_for_type", "change_for_id"], name: "index_candidate_changes_on_change_for_type_and_change_for_id"
    t.index ["vacancy_id"], name: "index_candidate_changes_on_vacancy_id"
  end

  create_table "candidate_ratings", id: :serial, force: :cascade do |t|
    t.integer "rating_type"
    t.integer "value"
    t.string "comment"
    t.integer "vacancy_stage_id"
    t.integer "candidate_vacancy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "commenter_id"
    t.integer "company_id"
    t.index ["candidate_vacancy_id"], name: "index_candidate_ratings_on_candidate_vacancy_id"
    t.index ["vacancy_stage_id"], name: "index_candidate_ratings_on_vacancy_stage_id"
  end

  create_table "candidate_vacancies", id: :serial, force: :cascade do |t|
    t.integer "candidate_id"
    t.integer "vacancy_id"
    t.integer "current_vacancy_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count"
    t.integer "company_id"
    t.index ["candidate_id"], name: "index_candidate_vacancies_on_candidate_id"
    t.index ["vacancy_id"], name: "index_candidate_vacancies_on_vacancy_id"
  end

  create_table "candidates", id: :serial, force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.date "birthdate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vacancy_id"
    t.integer "company_id"
    t.index ["company_id"], name: "index_candidates_on_company_id"
  end

  create_table "ckeditor_assets", id: :serial, force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.integer "assetable_id"
    t.string "assetable_type", limit: 30
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable"
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "body"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commentable_type"
    t.integer "commentable_id"
    t.integer "parent_comment_id"
    t.integer "account_id"
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.integer "likes_count", default: 0
    t.integer "company_id"
    t.boolean "service", default: false, null: false
    t.index ["account_id"], name: "index_comments_on_account_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "communities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "c_type"
    t.text "description"
    t.string "photo"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "documents", default: [], array: true
    t.integer "company_id"
    t.index ["account_id"], name: "index_communities_on_account_id"
  end

  create_table "communities_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "community_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["community_id"], name: "index_communities_users_on_community_id"
    t.index ["user_id"], name: "index_communities_users_on_user_id"
  end

  create_table "companies", id: :serial, force: :cascade do |t|
    t.string "name", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain"
    t.string "subdomain"
    t.boolean "default", default: false
  end

  create_table "components", force: :cascade do |t|
    t.bigint "company_id"
    t.string "name"
    t.boolean "enabled", default: true
    t.bigint "core_component_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_components_on_company_id"
    t.index ["core_component_id"], name: "index_components_on_core_component_id"
  end

  create_table "confirm_skills", id: :serial, force: :cascade do |t|
    t.integer "resume_skill_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_confirm_skills_on_account_id"
    t.index ["resume_skill_id"], name: "index_confirm_skills_on_resume_skill_id"
  end

  create_table "contact_emails", id: :serial, force: :cascade do |t|
    t.integer "kind", default: 0
    t.string "contactable_type"
    t.integer "contactable_id"
    t.string "email"
    t.boolean "preferable", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["contactable_type", "contactable_id"], name: "index_contact_emails_on_contactable_type_and_contactable_id"
  end

  create_table "contact_messengers", id: :serial, force: :cascade do |t|
    t.integer "name"
    t.string "contactable_type"
    t.integer "contactable_id"
    t.jsonb "phones"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["contactable_type", "contactable_id"], name: "index_contact_messengers_on_contactable_type_and_contactable_id"
  end

  create_table "contact_phones", id: :serial, force: :cascade do |t|
    t.integer "kind", default: 0
    t.string "contactable_type"
    t.integer "contactable_id"
    t.string "number"
    t.boolean "preferable", default: false
    t.boolean "whatsapp", default: false
    t.boolean "telegram", default: false
    t.boolean "viber", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["contactable_type", "contactable_id"], name: "index_contact_phones_on_contactable_type_and_contactable_id"
  end

  create_table "contacts_services", id: :serial, force: :cascade do |t|
    t.integer "service_id"
    t.integer "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["contact_id"], name: "index_contacts_services_on_contact_id"
    t.index ["service_id"], name: "index_contacts_services_on_service_id"
  end

  create_table "contract_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "counterparties", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "position"
    t.integer "customer_id"
    t.boolean "responsible", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["customer_id"], name: "index_counterparties_on_customer_id"
  end

  create_table "counterparties_information_about_participants", id: :serial, force: :cascade do |t|
    t.integer "counterparty_id"
    t.integer "information_about_participant_id"
    t.integer "company_id"
    t.index ["counterparty_id"], name: "index_cntprts_info_about_participants_on_cntrprt_id"
    t.index ["information_about_participant_id"], name: "index_cntrprts_iap_on_iap_id"
  end

  create_table "customer_contacts", id: :serial, force: :cascade do |t|
    t.integer "customer_id"
    t.string "name"
    t.string "city"
    t.string "position"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "skype"
    t.integer "comments_count", default: 0
    t.jsonb "social_urls", default: []
    t.integer "company_id"
    t.index ["customer_id"], name: "index_customer_contacts_on_customer_id"
  end

  create_table "customer_projects", id: :serial, force: :cascade do |t|
    t.integer "customer_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["customer_id"], name: "index_customer_projects_on_customer_id"
    t.index ["project_id"], name: "index_customer_projects_on_project_id"
  end

  create_table "customers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "departments", id: :serial, force: :cascade do |t|
    t.integer "company_id"
    t.string "code"
    t.string "name_ru"
    t.integer "parent_id"
    t.integer "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legal_unit_id"
    t.integer "manager_id"
    t.string "logo"
    t.index ["company_id"], name: "index_departments_on_company_id"
    t.index ["legal_unit_id"], name: "index_departments_on_legal_unit_id"
    t.index ["manager_id"], name: "index_departments_on_manager_id"
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "discussers", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "discussion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.boolean "left", default: false, null: false
    t.boolean "faved", default: false, null: false
    t.datetime "left_at"
    t.index ["account_id"], name: "index_discussers_on_account_id"
    t.index ["discussion_id"], name: "index_discussers_on_discussion_id"
  end

  create_table "discussions", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "body", default: "", null: false
    t.integer "author_id"
    t.integer "state", default: 0, null: false
    t.integer "comments_count", default: 0
    t.boolean "available_to_all", default: false, null: false
    t.string "discussable_type"
    t.integer "discussable_id"
    t.datetime "last_comment_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0
    t.integer "company_id"
    t.string "logo"
    t.index ["author_id"], name: "index_discussions_on_author_id"
    t.index ["discussable_type", "discussable_id"], name: "index_discussions_on_discussable_type_and_discussable_id"
  end

  create_table "documents", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.integer "document_attachable_id"
    t.string "document_attachable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "size", default: 0, null: false
    t.string "extension"
    t.integer "uploaded_by_id"
    t.integer "company_id"
    t.index ["uploaded_by_id"], name: "index_documents_on_uploaded_by_id"
  end

  create_table "education_levels", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "event_participants", id: :serial, force: :cascade do |t|
    t.integer "event_id"
    t.string "email"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_event_participants_on_account_id"
    t.index ["event_id"], name: "index_event_participants_on_event_id"
  end

  create_table "event_types", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text "description"
    t.integer "event_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "place"
    t.integer "created_by_id"
    t.boolean "available_for_all", default: false, null: false
    t.integer "participants_count", default: 0, null: false
    t.integer "company_id"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["event_type_id"], name: "index_events_on_event_type_id"
  end

  create_table "favorite_discussions", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "discussion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_favorite_discussions_on_account_id"
    t.index ["discussion_id"], name: "index_favorite_discussions_on_discussion_id"
  end

  create_table "favorite_posts", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_favorite_posts_on_account_id"
    t.index ["post_id"], name: "index_favorite_posts_on_post_id"
  end

  create_table "indicators", force: :cascade do |t|
    t.string "name"
    t.bigint "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_indicators_on_company_id"
    t.index ["skill_id"], name: "index_indicators_on_skill_id"
  end

  create_table "info360_source_github_repositories", id: :serial, force: :cascade do |t|
    t.integer "info360_source_github_id"
    t.string "url"
    t.boolean "fork"
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["info360_source_github_id"], name: "info360_source_github_on_github_id"
  end

  create_table "info360_source_githubs", id: :serial, force: :cascade do |t|
    t.integer "info360_id"
    t.string "account_url"
    t.datetime "last_events_date"
    t.boolean "hire_able"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["info360_id"], name: "index_info360_source_githubs_on_info360_id"
  end

  create_table "info360s", id: :serial, force: :cascade do |t|
    t.integer "candidate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["candidate_id"], name: "index_info360s_on_candidate_id"
  end

  create_table "information_about_participants", id: :serial, force: :cascade do |t|
    t.integer "representation_allowance_id"
    t.string "organization_name"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "customer_id"
    t.integer "company_id"
    t.index ["customer_id"], name: "index_information_about_participants_on_customer_id"
    t.index ["project_id"], name: "index_information_about_participants_on_project_id"
    t.index ["representation_allowance_id"], name: "index_inf_ab_participants_on_repr_allowance_id"
  end

  create_table "language_levels", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "language_skills", id: :serial, force: :cascade do |t|
    t.integer "resume_id"
    t.integer "language_id"
    t.integer "language_level_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["language_id"], name: "index_language_skills_on_language_id"
    t.index ["language_level_id"], name: "index_language_skills_on_language_level_id"
    t.index ["resume_id"], name: "index_language_skills_on_resume_id"
  end

  create_table "languages", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "legal_unit_employee_positions", id: :serial, force: :cascade do |t|
    t.string "department_code"
    t.string "position_code"
    t.date "order_date"
    t.string "order_number"
    t.string "order_author"
    t.integer "legal_unit_employee_id"
    t.integer "transfer_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["legal_unit_employee_id"], name: "index_legal_unit_employee_positions_on_legal_unit_employee_id"
  end

  create_table "legal_unit_employee_states", id: :serial, force: :cascade do |t|
    t.string "state"
    t.datetime "changed_at"
    t.integer "changed_by"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "legal_unit_employees", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "legal_unit_id"
    t.boolean "default"
    t.string "employee_number"
    t.string "employee_uid"
    t.string "individual_employee_uid"
    t.string "email_corporate"
    t.string "email_work"
    t.string "phone_corporate"
    t.string "phone_work"
    t.date "hired_at"
    t.integer "legal_unit_employee_state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "manager_id"
    t.integer "office_id"
    t.float "wage"
    t.float "wage_rate"
    t.float "pay"
    t.float "extrapay"
    t.date "contract_end_at"
    t.integer "contract_type_id"
    t.string "contract_id"
    t.string "probation_period"
    t.date "starts_work_at"
    t.string "structure_unit"
    t.integer "company_id"
    t.index ["account_id"], name: "index_legal_unit_employees_on_account_id"
    t.index ["legal_unit_employee_state_id"], name: "index_legal_unit_employees_on_legal_unit_employee_state_id"
    t.index ["legal_unit_id"], name: "index_legal_unit_employees_on_legal_unit_id"
    t.index ["manager_id"], name: "index_legal_unit_employees_on_manager_id"
    t.index ["office_id"], name: "index_legal_unit_employees_on_office_id"
  end

  create_table "legal_units", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "uuid"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "logo"
    t.string "full_name"
    t.string "legal_address"
    t.string "inn_number"
    t.string "kpp_number"
    t.string "ogrn_number"
    t.string "city"
    t.string "general_director"
    t.string "administrative_director"
    t.string "general_accountant"
    t.string "external_id"
    t.string "external_system"
    t.integer "assistant_id"
    t.index ["company_id"], name: "index_legal_units_on_company_id"
  end

  create_table "likes", id: :serial, force: :cascade do |t|
    t.string "likable_type"
    t.integer "likable_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_likes_on_account_id"
    t.index ["likable_type", "likable_id"], name: "index_likes_on_likable_type_and_likable_id"
  end

  create_table "mailing_lists", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description", default: "", null: false
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "importable_type"
    t.integer "importable_id"
    t.integer "company_id"
    t.index ["account_id"], name: "index_mailing_lists_on_account_id"
    t.index ["importable_id", "importable_type"], name: "index_mailing_lists_on_importable_id_and_importable_type"
  end

  create_table "meeting_informations", id: :serial, force: :cascade do |t|
    t.integer "representation_allowance_id"
    t.datetime "starts_at"
    t.string "place"
    t.string "address"
    t.text "aim"
    t.text "result"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["representation_allowance_id"], name: "index_meeting_informations_on_representation_allowance_id"
  end

  create_table "mentions", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mentionable_type"
    t.integer "mentionable_id"
    t.integer "company_id"
    t.index ["account_id"], name: "index_mentions_on_account_id"
    t.index ["mentionable_type", "mentionable_id"], name: "index_mentions_on_mentionable_type_and_mentionable_id"
    t.index ["post_id"], name: "index_mentions_on_post_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.text "body"
    t.integer "topic_id"
    t.integer "parent_message_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["parent_message_id"], name: "index_messages_on_parent_message_id"
    t.index ["topic_id"], name: "index_messages_on_topic_id"
  end

  create_table "news_categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
  end

  create_table "news_items", id: :serial, force: :cascade do |t|
    t.integer "news_category_id"
    t.integer "account_id"
    t.string "state"
    t.string "title"
    t.string "preview"
    t.text "body"
    t.boolean "on_top", default: false, null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "community_id"
    t.integer "comments_count", default: 0
    t.boolean "allow_commenting", default: true, null: false
    t.integer "likes_count", default: 0
    t.bigint "company_id"
    t.index ["account_id"], name: "index_news_items_on_account_id"
    t.index ["community_id"], name: "index_news_items_on_community_id"
    t.index ["news_category_id"], name: "index_news_items_on_news_category_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.string "notice_type"
    t.integer "notice_id"
    t.string "body", limit: 256
    t.boolean "dispatch"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_notification"
    t.integer "company_id"
    t.index ["account_id"], name: "index_notifications_on_account_id"
    t.index ["notice_type", "notice_id"], name: "index_notifications_on_notice_type_and_notice_id"
  end

  create_table "offered_variants", id: :serial, force: :cascade do |t|
    t.integer "question_id"
    t.string "wording"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.integer "position"
    t.integer "company_id"
    t.index ["question_id"], name: "index_offered_variants_on_question_id"
  end

  create_table "offices", id: :serial, force: :cascade do |t|
    t.string "name", limit: 200
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "participants", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.integer "information_about_participant_id"
    t.string "position"
    t.integer "type_of_participant"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "responsible"
    t.integer "company_id"
    t.index ["account_id"], name: "index_participants_on_account_id"
    t.index ["information_about_participant_id"], name: "index_participants_on_information_about_participant_id"
  end

  create_table "permissions", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "personal_notifications", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.string "title", default: "", null: false
    t.string "icon"
    t.boolean "read", default: false, null: false
    t.text "body", default: "", null: false
    t.integer "group_type", default: 0, null: false
    t.integer "module_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "issuer_type"
    t.integer "issuer_id"
    t.jsonb "parent"
    t.integer "company_id"
    t.index ["account_id"], name: "index_personal_notifications_on_account_id"
    t.index ["issuer_type", "issuer_id"], name: "index_personal_notifications_on_issuer_type_and_issuer_id"
  end

  create_table "pgbench_accounts", primary_key: "aid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "bid"
    t.integer "abalance"
    t.string "filler", limit: 84
  end

  create_table "pgbench_branches", primary_key: "bid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "bbalance"
    t.string "filler", limit: 88
  end

  create_table "pgbench_history", id: false, force: :cascade do |t|
    t.integer "tid"
    t.integer "bid"
    t.integer "aid"
    t.integer "delta"
    t.datetime "mtime"
    t.string "filler", limit: 22
  end

  create_table "pgbench_tellers", primary_key: "tid", id: :integer, default: nil, force: :cascade do |t|
    t.integer "bid"
    t.integer "tbalance"
    t.string "filler", limit: 84
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.integer "photo_attachable_id"
    t.string "photo_attachable_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "position_groups", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name_ru"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legal_unit_id"
    t.integer "company_id"
    t.index ["company_id"], name: "index_position_groups_on_company_id"
    t.index ["legal_unit_id"], name: "index_position_groups_on_legal_unit_id"
  end

  create_table "positions", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "name_ru"
    t.text "description"
    t.string "position_group_code"
    t.integer "salary_from"
    t.integer "salary_up"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legal_unit_id"
    t.integer "company_id"
    t.index ["company_id"], name: "index_positions_on_company_id"
    t.index ["legal_unit_id"], name: "index_positions_on_legal_unit_id"
    t.index ["position_group_code"], name: "index_positions_on_position_group_code"
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.integer "author_id"
    t.integer "community_id"
    t.string "name"
    t.string "body"
    t.boolean "allow_commenting", default: true
    t.datetime "edited_at"
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes_count", default: 0
    t.integer "comments_count", default: 0
    t.integer "company_id"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["community_id"], name: "index_posts_on_community_id"
    t.index ["deleted_by_id"], name: "index_posts_on_deleted_by_id"
  end

  create_table "professional_areas", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "professional_specializations", id: :serial, force: :cascade do |t|
    t.integer "professional_area_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["professional_area_id"], name: "index_professional_specializations_on_professional_area_id"
  end

  create_table "professional_specializations_resumes", id: :serial, force: :cascade do |t|
    t.integer "resume_id"
    t.integer "professional_specialization_id"
    t.integer "company_id"
    t.index ["professional_specialization_id"], name: "index_professional_specializations_resumes_on_prof_spec_id"
    t.index ["resume_id"], name: "index_professional_specializations_resumes_on_resume_id"
  end

  create_table "profile_achievements", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "achievement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["achievement_id"], name: "index_profile_achievements_on_achievement_id"
    t.index ["profile_id"], name: "index_profile_achievements_on_profile_id"
  end

  create_table "profile_emails", id: :serial, force: :cascade do |t|
    t.string "email"
    t.boolean "preferable", default: false
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind"
    t.integer "company_id"
    t.index ["profile_id"], name: "index_profile_emails_on_profile_id"
  end

  create_table "profile_mailing_lists", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "mailing_list_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["mailing_list_id"], name: "index_profile_mailing_lists_on_mailing_list_id"
    t.index ["profile_id", "mailing_list_id"], name: "index_profile_mailing_lists_on_profile_id_and_mailing_list_id", unique: true
    t.index ["profile_id"], name: "index_profile_mailing_lists_on_profile_id"
  end

  create_table "profile_messengers", id: :serial, force: :cascade do |t|
    t.integer "name"
    t.integer "profile_id"
    t.jsonb "phones", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["profile_id"], name: "index_profile_messengers_on_profile_id"
  end

  create_table "profile_phones", id: :serial, force: :cascade do |t|
    t.integer "kind"
    t.string "number"
    t.boolean "preferable", default: false
    t.boolean "whatsapp", default: false
    t.boolean "telegram", default: false
    t.boolean "viber", default: false
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["profile_id"], name: "index_profile_phones_on_profile_id"
  end

  create_table "profile_projects", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "feedback"
    t.integer "rating"
    t.integer "worked_hours"
    t.string "status"
    t.date "gone_date"
    t.integer "company_id"
  end

  create_table "profile_reading_entities", id: :serial, force: :cascade do |t|
    t.integer "profile_id"
    t.string "readable_type"
    t.integer "readable_id"
    t.datetime "last_read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["profile_id"], name: "index_profile_reading_entities_on_profile_id"
    t.index ["readable_type", "readable_id"], name: "index_profile_reading_entities_on_readable_type_and_readable_id"
  end

  create_table "profiles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "surname", limit: 100
    t.string "name", limit: 100
    t.string "middlename", limit: 100
    t.string "photo", limit: 200
    t.date "birthday"
    t.string "skype", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sex"
    t.string "city"
    t.jsonb "social_urls", default: []
    t.integer "updater_id"
    t.integer "marital_status"
    t.integer "kids", default: 0, null: false
    t.integer "company_id"
    t.integer "balance", default: 0
    t.index ["company_id"], name: "index_profiles_on_company_id"
  end

  create_table "project_role_skills", force: :cascade do |t|
    t.bigint "skill_id"
    t.bigint "project_role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_project_role_skills_on_company_id"
    t.index ["project_role_id"], name: "index_project_role_skills_on_project_role_id"
    t.index ["skill_id"], name: "index_project_role_skills_on_skill_id"
  end

  create_table "project_roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.integer "skills_count", default: 0, null: false
    t.index ["company_id"], name: "index_project_roles_on_company_id"
    t.index ["name"], name: "index_project_roles_on_name"
  end

  create_table "project_work_periods", id: :serial, force: :cascade do |t|
    t.integer "account_project_id"
    t.date "begin_date"
    t.date "end_date"
    t.string "role"
    t.string "duties"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_project_id"], name: "index_project_work_periods_on_account_project_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "title", limit: 1024
    t.string "description", limit: 1000
    t.integer "manager_id"
    t.date "begin_date"
    t.date "end_date"
    t.string "status", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "legal_unit_id"
    t.string "charge_code"
    t.integer "department_id"
    t.integer "account_projects_count", default: 0
    t.integer "created_by_id"
    t.integer "updated_by_id"
    t.integer "company_id"
    t.index ["company_id"], name: "index_projects_on_company_id"
    t.index ["department_id"], name: "index_projects_on_department_id"
    t.index ["legal_unit_id"], name: "index_projects_on_legal_unit_id"
    t.index ["manager_id"], name: "index_projects_on_manager_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "survey_id"
    t.string "image"
    t.text "wording"
    t.boolean "ban_own_answer", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "question_type"
    t.integer "company_id"
    t.index ["survey_id"], name: "index_questions_on_survey_id"
  end

  create_table "representation_allowances", id: :serial, force: :cascade do |t|
    t.integer "bid_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["bid_id"], name: "index_representation_allowances_on_bid_id"
  end

  create_table "resume_certificates", id: :serial, force: :cascade do |t|
    t.string "name", limit: 200
    t.date "start_date"
    t.date "end_date"
    t.integer "resume_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.string "file"
    t.integer "company_id"
    t.index ["resume_id"], name: "index_resume_certificates_on_resume_id"
  end

  create_table "resume_contacts", id: :serial, force: :cascade do |t|
    t.integer "resume_id"
    t.integer "contact_type", default: 0
    t.string "value"
    t.boolean "preferred", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["resume_id"], name: "index_resume_contacts_on_resume_id"
  end

  create_table "resume_courses", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.integer "resume_id"
    t.string "end_year"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["resume_id"], name: "index_resume_courses_on_resume_id"
  end

  create_table "resume_educations", id: :serial, force: :cascade do |t|
    t.string "school_name"
    t.string "faculty_name"
    t.string "speciality"
    t.integer "end_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "resume_id"
    t.integer "education_level_id"
    t.integer "company_id"
    t.index ["education_level_id"], name: "index_resume_educations_on_education_level_id"
    t.index ["resume_id"], name: "index_resume_educations_on_resume_id"
  end

  create_table "resume_qualifications", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "company_name"
    t.string "speciality"
    t.integer "resume_id"
    t.string "end_year"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["resume_id"], name: "index_resume_qualifications_on_resume_id"
  end

  create_table "resume_recommendations", id: :serial, force: :cascade do |t|
    t.integer "resume_id"
    t.string "recommender_name"
    t.string "company_and_position"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["resume_id"], name: "index_resume_recommendations_on_resume_id"
  end

  create_table "resume_skills", id: :serial, force: :cascade do |t|
    t.integer "resume_id"
    t.integer "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["resume_id", "skill_id"], name: "index_resume_skills_on_resume_id_and_skill_id"
  end

  create_table "resume_sources", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "resume_work_experiences", id: :serial, force: :cascade do |t|
    t.integer "resume_id"
    t.string "position"
    t.string "company_name"
    t.string "region"
    t.string "website"
    t.date "start_date"
    t.date "end_date"
    t.text "experience_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["resume_id"], name: "index_resume_work_experiences_on_resume_id"
  end

  create_table "resumes", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "city"
    t.date "birthdate"
    t.string "photo"
    t.integer "sex"
    t.integer "martial_condition"
    t.integer "have_children"
    t.text "skills_description"
    t.string "desired_position"
    t.integer "salary_level"
    t.jsonb "employment_type"
    t.jsonb "working_schedule"
    t.text "comment"
    t.integer "vacancy_id"
    t.jsonb "documents"
    t.integer "professional_specialization_id"
    t.integer "candidate_id"
    t.integer "education_level_id"
    t.jsonb "experience"
    t.integer "resume_source_id"
    t.string "specialization"
    t.string "source_id"
    t.date "source_updated_at"
    t.string "resume_text"
    t.boolean "parsed", default: false
    t.integer "raw_resume_doc_id"
    t.integer "last_requested_work_period", default: 0
    t.date "work_period_request_expiration_date", default: "2018-03-21"
    t.boolean "primary", default: true, null: false
    t.string "resume_file"
    t.boolean "manual", default: true, null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_resumes_on_account_id"
    t.index ["candidate_id"], name: "index_resumes_on_candidate_id"
    t.index ["education_level_id"], name: "index_resumes_on_education_level_id"
    t.index ["professional_specialization_id"], name: "index_resumes_on_professional_specialization_id"
    t.index ["resume_source_id"], name: "index_resumes_on_resume_source_id"
    t.index ["vacancy_id"], name: "index_resumes_on_vacancy_id"
  end

  create_table "role_functions", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.string "module_code", limit: 100
    t.string "function_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["role_id"], name: "index_role_functions_on_role_id"
  end

  create_table "role_permissions", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.integer "permission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "role_rights", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.string "module_code", limit: 100
    t.string "object_code", limit: 100
    t.string "group_code", limit: 20
    t.integer "rights"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["role_id"], name: "index_role_rights_on_role_id"
  end

  create_table "role_users", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["role_id"], name: "index_role_users_on_role_id"
    t.index ["user_id"], name: "index_role_users_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "service_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
  end

  create_table "services", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "state"
    t.datetime "published_at"
    t.integer "service_group_id"
    t.integer "bid_stages_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "is_provided_them"
    t.text "order_service"
    t.text "results"
    t.text "term_for_ranting"
    t.text "restrictions"
    t.text "process_description"
    t.boolean "is_bid_required"
    t.text "supporting_documents"
    t.bigint "company_id"
    t.index ["bid_stages_group_id"], name: "index_services_on_bid_stages_group_id"
    t.index ["service_group_id"], name: "index_services_on_service_group_id"
  end

  create_table "settings", id: :serial, force: :cascade do |t|
    t.string "code"
    t.string "label"
    t.string "value"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "kind", default: 0, null: false
    t.bigint "settings_group_id"
    t.index ["company_id"], name: "index_settings_on_company_id"
    t.index ["settings_group_id"], name: "index_settings_on_settings_group_id"
  end

  create_table "settings_groups", force: :cascade do |t|
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_settings_groups_on_company_id"
  end

  create_table "similar_candidates_pairs", id: :serial, force: :cascade do |t|
    t.integer "first_candidate_id"
    t.integer "second_candidate_id"
    t.boolean "checked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["first_candidate_id", "second_candidate_id"], name: "similar_candidates_index", unique: true
  end

  create_table "skill_confirmations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "account_id"
    t.bigint "account_skill_id"
    t.integer "company_id"
    t.index ["account_skill_id"], name: "index_skill_confirmations_on_account_skill_id"
  end

  create_table "skills", id: :serial, force: :cascade do |t|
    t.string "name", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.integer "company_id"
    t.string "description"
    t.integer "indicators_count", default: 0, null: false
    t.index ["project_id"], name: "index_skills_on_project_id"
  end

  create_table "survey_answers", id: :serial, force: :cascade do |t|
    t.integer "survey_result_id"
    t.integer "question_id"
    t.jsonb "answers", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["question_id"], name: "index_survey_answers_on_question_id"
    t.index ["survey_result_id"], name: "index_survey_answers_on_survey_result_id"
  end

  create_table "survey_participants", id: :serial, force: :cascade do |t|
    t.integer "survey_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id", "survey_id"], name: "index_survey_participants_on_account_id_and_survey_id"
    t.index ["account_id"], name: "index_survey_participants_on_account_id"
    t.index ["survey_id"], name: "index_survey_participants_on_survey_id"
  end

  create_table "survey_results", id: :serial, force: :cascade do |t|
    t.integer "survey_id"
    t.integer "account_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["account_id"], name: "index_survey_results_on_account_id"
    t.index ["survey_id"], name: "index_survey_results_on_survey_id"
  end

  create_table "surveys", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "symbol"
    t.string "state"
    t.string "document"
    t.text "note"
    t.integer "survey_type"
    t.boolean "anonymous", default: false
    t.integer "creator_id"
    t.integer "editor_id"
    t.integer "publisher_id"
    t.integer "unpublisher_id"
    t.datetime "published_at"
    t.datetime "unpublished_at"
    t.datetime "ends_at"
    t.string "background", default: "#ffffff"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available_to_all", default: true, null: false
    t.integer "participants_passed_count", default: 0, null: false
    t.integer "participants_total_count", default: 0, null: false
    t.integer "questions_count", default: 0, null: false
    t.bigint "company_id"
    t.index ["creator_id"], name: "index_surveys_on_creator_id"
    t.index ["editor_id"], name: "index_surveys_on_editor_id"
    t.index ["publisher_id"], name: "index_surveys_on_publisher_id"
    t.index ["unpublisher_id"], name: "index_surveys_on_unpublisher_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.integer "company_id"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.integer "company_id"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "task_observers", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_id"], name: "index_task_observers_on_account_id"
    t.index ["task_id"], name: "index_task_observers_on_task_id"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "description", default: "", null: false
    t.integer "priority"
    t.boolean "displayed_in_calendar", default: false, null: false
    t.boolean "done", default: false, null: false
    t.integer "parent_id"
    t.datetime "executed_at"
    t.datetime "ends_at"
    t.integer "executor_id"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_subtasks_count", default: 0, null: false
    t.integer "executed_subtasks_count", default: 0, null: false
    t.string "taskable_type"
    t.bigint "taskable_id"
    t.integer "company_id"
    t.index ["author_id"], name: "index_tasks_on_author_id"
    t.index ["executor_id"], name: "index_tasks_on_executor_id"
    t.index ["parent_id"], name: "index_tasks_on_parent_id"
    t.index ["taskable_type", "taskable_id"], name: "index_tasks_on_taskable_type_and_taskable_id"
  end

  create_table "team_building_information_accounts", force: :cascade do |t|
    t.bigint "account_id"
    t.integer "company_id"
    t.bigint "team_building_information_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_team_building_information_accounts_on_account_id"
    t.index ["company_id"], name: "index_team_building_information_accounts_on_company_id"
    t.index ["team_building_information_id"], name: "index_team_building_info_accounts_tb_id"
  end

  create_table "team_building_information_legal_units", force: :cascade do |t|
    t.bigint "legal_unit_id"
    t.bigint "team_building_information_id"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_team_building_information_legal_units_on_company_id"
    t.index ["legal_unit_id"], name: "index_team_building_information_legal_units_on_legal_unit_id"
    t.index ["team_building_information_id"], name: "index_team_building_lu_tb_id"
  end

  create_table "team_building_informations", force: :cascade do |t|
    t.bigint "bid_id"
    t.integer "company_id"
    t.integer "number_of_participants"
    t.string "event_format"
    t.integer "approx_cost"
    t.string "additional_info"
    t.datetime "event_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.bigint "project_id"
    t.index ["bid_id"], name: "index_team_building_informations_on_bid_id"
    t.index ["company_id"], name: "index_team_building_informations_on_company_id"
    t.index ["project_id"], name: "index_team_building_informations_on_project_id"
  end

  create_table "template_stages", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
  end

  create_table "topics", id: :serial, force: :cascade do |t|
    t.string "subject", limit: 70
    t.string "photo"
    t.integer "community_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["community_id"], name: "index_topics_on_community_id"
  end

  create_table "transactions", id: :serial, force: :cascade do |t|
    t.integer "kind"
    t.string "comment"
    t.integer "value", default: 0
    t.integer "account_achievement_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["account_achievement_id"], name: "index_transactions_on_account_achievement_id"
    t.index ["recipient_id"], name: "index_transactions_on_recipient_id"
  end

  create_table "ui_settings", force: :cascade do |t|
    t.bigint "company_id"
    t.string "active_color", null: false
    t.string "active_color_light", null: false
    t.string "active_color_dark", null: false
    t.string "base_color", null: false
    t.string "menu_color", null: false
    t.string "main_logo"
    t.string "signin_logo"
    t.string "signin_animation"
    t.string "main_page_picture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "signin_picture", default: "", null: false
    t.string "side_menu_color", default: "", null: false
    t.string "head_menu_item", default: "", null: false
    t.string "head_menu_item_active", default: "", null: false
    t.string "head_menu_item_hover", default: "", null: false
    t.index ["company_id"], name: "index_ui_settings_on_company_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "status", limit: 15
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.string "login"
    t.string "external_id"
    t.string "external_system"
    t.index ["company_id", "email"], name: "index_users_on_company_id_and_email"
    t.index ["company_id", "login"], name: "index_users_on_company_id_and_login"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_vacancies", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "vacancy_id"
    t.string "full_name"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["user_id"], name: "index_users_vacancies_on_user_id"
    t.index ["vacancy_id"], name: "index_users_vacancies_on_vacancy_id"
  end

  create_table "vacancies", id: :serial, force: :cascade do |t|
    t.string "status"
    t.string "name"
    t.integer "positions_count"
    t.text "demands"
    t.text "duties"
    t.jsonb "experience"
    t.jsonb "schedule"
    t.jsonb "type_of_employment"
    t.integer "type_of_salary"
    t.integer "level_of_salary_from"
    t.integer "level_of_salary_to"
    t.boolean "show_salary"
    t.integer "type_of_contract"
    t.string "place_of_work"
    t.text "comment"
    t.date "ends_at"
    t.text "comment_for_employee"
    t.text "additional_tests"
    t.string "file"
    t.text "reason_for_opening"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_stage_id"
    t.integer "manager_id"
    t.integer "owner_id"
    t.integer "creator_id"
    t.string "legal_unit"
    t.string "block"
    t.string "practice"
    t.string "project"
    t.integer "company_id"
    t.index ["company_id"], name: "index_vacancies_on_company_id"
    t.index ["creator_id"], name: "index_vacancies_on_creator_id"
    t.index ["owner_id"], name: "index_vacancies_on_owner_id"
  end

  create_table "vacancy_stage_groups", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "color"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "company_id"
  end

  create_table "vacancy_stages", id: :serial, force: :cascade do |t|
    t.integer "vacancy_id"
    t.boolean "need_notification"
    t.boolean "evaluation_of_candidate"
    t.integer "type_of_rating"
    t.integer "template_stage_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.boolean "editable"
    t.boolean "must_be_last"
    t.string "name"
    t.integer "group_name"
    t.integer "vacancy_stage_group_id"
    t.boolean "can_create_left", default: true
    t.boolean "can_create_right", default: true
    t.integer "candidate_vacancies_count", default: 0
    t.integer "company_id"
    t.index ["template_stage_id"], name: "index_vacancy_stages_on_template_stage_id"
    t.index ["vacancy_id"], name: "index_vacancy_stages_on_vacancy_id"
    t.index ["vacancy_stage_group_id"], name: "index_vacancy_stages_on_vacancy_stage_group_id"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.integer "company_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "account_achievements", "accounts"
  add_foreign_key "account_achievements", "achievements"
  add_foreign_key "account_communities", "accounts"
  add_foreign_key "account_communities", "communities"
  add_foreign_key "account_emails", "accounts"
  add_foreign_key "account_mailing_lists", "accounts"
  add_foreign_key "account_mailing_lists", "mailing_lists"
  add_foreign_key "account_messengers", "accounts"
  add_foreign_key "account_phones", "accounts"
  add_foreign_key "account_photos", "accounts"
  add_foreign_key "account_projects", "accounts"
  add_foreign_key "account_projects", "projects"
  add_foreign_key "account_reading_entities", "accounts"
  add_foreign_key "account_roles", "accounts"
  add_foreign_key "account_roles", "roles"
  add_foreign_key "account_skills", "accounts"
  add_foreign_key "account_skills", "skills"
  add_foreign_key "account_vacancies", "accounts"
  add_foreign_key "account_vacancies", "vacancies"
  add_foreign_key "allowed_bid_stages", "bid_stages", column: "allowed_stage_id", on_delete: :cascade
  add_foreign_key "allowed_bid_stages", "bid_stages", column: "current_stage_id", on_delete: :cascade
  add_foreign_key "allowed_bid_stages", "bids_executors", column: "additional_executor_id"
  add_foreign_key "allowed_bid_stages_bids_executors", "allowed_bid_stages"
  add_foreign_key "allowed_bid_stages_bids_executors", "bids_executors"
  add_foreign_key "assessment_indicator_evaluations", "assessment_skill_evaluations"
  add_foreign_key "assessment_indicator_evaluations", "indicators"
  add_foreign_key "assessment_participants", "accounts"
  add_foreign_key "assessment_participants", "assessment_sessions"
  add_foreign_key "assessment_session_evaluations", "accounts"
  add_foreign_key "assessment_session_evaluations", "assessment_sessions"
  add_foreign_key "assessment_session_skills", "assessment_sessions"
  add_foreign_key "assessment_session_skills", "skills"
  add_foreign_key "assessment_sessions", "accounts"
  add_foreign_key "assessment_sessions", "project_roles"
  add_foreign_key "assessment_skill_evaluations", "assessment_session_evaluations"
  add_foreign_key "assessment_skill_evaluations", "skills"
  add_foreign_key "assessment_spectators", "accounts"
  add_foreign_key "assessment_spectators", "assessment_sessions"
  add_foreign_key "bid_stages", "bid_stages_groups"
  add_foreign_key "bids", "accounts", column: "assistant_id"
  add_foreign_key "bids", "accounts", column: "author_id"
  add_foreign_key "bids", "accounts", column: "creator_id"
  add_foreign_key "bids", "accounts", column: "manager_id"
  add_foreign_key "bids", "accounts", column: "matching_user_id"
  add_foreign_key "bids", "legal_units"
  add_foreign_key "bids", "services", on_delete: :cascade
  add_foreign_key "bids_bid_stages", "bid_stages", on_delete: :cascade
  add_foreign_key "bids_bid_stages", "bids", on_delete: :cascade
  add_foreign_key "bids_executors", "accounts"
  add_foreign_key "bonus_information_approvers", "accounts"
  add_foreign_key "bonus_information_approvers", "bonus_informations"
  add_foreign_key "bonus_information_participants", "accounts"
  add_foreign_key "bonus_information_participants", "bonus_informations"
  add_foreign_key "bonus_information_participants", "bonus_reasons"
  add_foreign_key "bonus_information_participants", "legal_units"
  add_foreign_key "bonus_informations", "bids"
  add_foreign_key "bonus_informations", "bonus_reasons"
  add_foreign_key "byod_informations", "bids"
  add_foreign_key "candidate_changes", "accounts"
  add_foreign_key "candidate_changes", "candidates"
  add_foreign_key "candidate_changes", "vacancies"
  add_foreign_key "candidate_ratings", "accounts", column: "commenter_id"
  add_foreign_key "candidate_ratings", "candidate_vacancies"
  add_foreign_key "candidate_ratings", "vacancy_stages"
  add_foreign_key "candidate_vacancies", "candidates"
  add_foreign_key "candidate_vacancies", "vacancies"
  add_foreign_key "comments", "accounts"
  add_foreign_key "communities", "accounts"
  add_foreign_key "communities_users", "communities"
  add_foreign_key "communities_users", "users"
  add_foreign_key "components", "companies"
  add_foreign_key "confirm_skills", "accounts"
  add_foreign_key "contacts_services", "accounts", column: "contact_id"
  add_foreign_key "contacts_services", "services"
  add_foreign_key "counterparties", "customers"
  add_foreign_key "counterparties_information_about_participants", "counterparties"
  add_foreign_key "counterparties_information_about_participants", "information_about_participants"
  add_foreign_key "customer_projects", "customers"
  add_foreign_key "customer_projects", "projects"
  add_foreign_key "departments", "companies"
  add_foreign_key "departments", "legal_units"
  add_foreign_key "discussers", "accounts"
  add_foreign_key "discussers", "discussions"
  add_foreign_key "event_participants", "accounts"
  add_foreign_key "event_participants", "events"
  add_foreign_key "events", "event_types"
  add_foreign_key "favorite_discussions", "accounts"
  add_foreign_key "favorite_discussions", "discussions"
  add_foreign_key "favorite_posts", "accounts"
  add_foreign_key "favorite_posts", "posts"
  add_foreign_key "indicators", "skills"
  add_foreign_key "information_about_participants", "customers"
  add_foreign_key "information_about_participants", "projects", on_delete: :nullify
  add_foreign_key "information_about_participants", "representation_allowances", on_delete: :cascade
  add_foreign_key "language_skills", "language_levels"
  add_foreign_key "language_skills", "languages"
  add_foreign_key "language_skills", "resumes"
  add_foreign_key "legal_unit_employee_positions", "legal_unit_employees"
  add_foreign_key "legal_unit_employees", "accounts"
  add_foreign_key "legal_unit_employees", "accounts", column: "manager_id"
  add_foreign_key "legal_unit_employees", "legal_unit_employee_states"
  add_foreign_key "legal_unit_employees", "legal_units"
  add_foreign_key "legal_units", "accounts", column: "assistant_id"
  add_foreign_key "legal_units", "companies"
  add_foreign_key "likes", "accounts"
  add_foreign_key "mailing_lists", "accounts"
  add_foreign_key "meeting_informations", "representation_allowances", on_delete: :cascade
  add_foreign_key "mentions", "accounts"
  add_foreign_key "mentions", "posts"
  add_foreign_key "messages", "accounts"
  add_foreign_key "messages", "topics"
  add_foreign_key "news_items", "accounts"
  add_foreign_key "news_items", "news_categories"
  add_foreign_key "notifications", "accounts"
  add_foreign_key "offered_variants", "questions", on_delete: :cascade
  add_foreign_key "participants", "accounts"
  add_foreign_key "participants", "information_about_participants"
  add_foreign_key "personal_notifications", "accounts"
  add_foreign_key "position_groups", "legal_units"
  add_foreign_key "positions", "legal_units"
  add_foreign_key "posts", "accounts", column: "author_id"
  add_foreign_key "posts", "accounts", column: "deleted_by_id"
  add_foreign_key "professional_specializations", "professional_areas"
  add_foreign_key "professional_specializations_resumes", "professional_specializations"
  add_foreign_key "professional_specializations_resumes", "resumes"
  add_foreign_key "profile_achievements", "achievements"
  add_foreign_key "profile_achievements", "profiles"
  add_foreign_key "profile_emails", "profiles"
  add_foreign_key "profile_mailing_lists", "mailing_lists"
  add_foreign_key "profile_mailing_lists", "profiles"
  add_foreign_key "profile_messengers", "profiles"
  add_foreign_key "profile_phones", "profiles"
  add_foreign_key "profile_reading_entities", "profiles"
  add_foreign_key "project_role_skills", "project_roles"
  add_foreign_key "project_role_skills", "skills"
  add_foreign_key "project_work_periods", "account_projects"
  add_foreign_key "projects", "accounts", column: "created_by_id"
  add_foreign_key "projects", "accounts", column: "manager_id"
  add_foreign_key "projects", "accounts", column: "updated_by_id"
  add_foreign_key "projects", "departments"
  add_foreign_key "projects", "legal_units"
  add_foreign_key "questions", "surveys", on_delete: :cascade
  add_foreign_key "representation_allowances", "bids"
  add_foreign_key "resume_contacts", "resumes"
  add_foreign_key "resume_courses", "resumes"
  add_foreign_key "resume_qualifications", "resumes"
  add_foreign_key "resume_recommendations", "resumes"
  add_foreign_key "resume_work_experiences", "resumes"
  add_foreign_key "resumes", "resume_sources"
  add_foreign_key "role_functions", "roles"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "role_rights", "roles"
  add_foreign_key "role_users", "roles"
  add_foreign_key "role_users", "users"
  add_foreign_key "services", "bid_stages_groups", on_delete: :cascade
  add_foreign_key "services", "service_groups", on_delete: :cascade
  add_foreign_key "settings_groups", "companies"
  add_foreign_key "similar_candidates_pairs", "candidates", column: "first_candidate_id"
  add_foreign_key "similar_candidates_pairs", "candidates", column: "second_candidate_id"
  add_foreign_key "survey_answers", "questions", on_delete: :cascade
  add_foreign_key "survey_answers", "survey_results", on_delete: :cascade
  add_foreign_key "survey_participants", "accounts"
  add_foreign_key "survey_participants", "surveys"
  add_foreign_key "survey_results", "accounts"
  add_foreign_key "survey_results", "surveys", on_delete: :cascade
  add_foreign_key "surveys", "accounts", column: "creator_id"
  add_foreign_key "surveys", "accounts", column: "editor_id"
  add_foreign_key "surveys", "accounts", column: "publisher_id"
  add_foreign_key "surveys", "accounts", column: "unpublisher_id"
  add_foreign_key "task_observers", "accounts"
  add_foreign_key "task_observers", "tasks"
  add_foreign_key "team_building_information_accounts", "accounts"
  add_foreign_key "team_building_information_accounts", "team_building_informations"
  add_foreign_key "team_building_information_legal_units", "legal_units"
  add_foreign_key "team_building_information_legal_units", "team_building_informations"
  add_foreign_key "team_building_informations", "bids"
  add_foreign_key "team_building_informations", "projects"
  add_foreign_key "topics", "communities"
  add_foreign_key "transactions", "account_achievements"
  add_foreign_key "ui_settings", "companies"
end
