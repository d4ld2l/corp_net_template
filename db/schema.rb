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

ActiveRecord::Schema.define(version: 20171002094145) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "additional_contacts", force: :cascade do |t|
    t.integer  "type"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "resume_id"
    t.index ["resume_id"], name: "index_additional_contacts_on_resume_id", using: :btree
  end

  create_table "base64_documents", force: :cascade do |t|
    t.string   "file"
    t.string   "name"
    t.string   "base64_doc_attachable_type"
    t.integer  "base64_doc_attachable_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["base64_doc_attachable_type", "base64_doc_attachable_id"], name: "index_base64_documents_on_base64_doc_attachable", using: :btree
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
    t.index ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.string   "body"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.integer  "parent_comment_id"
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "communities", force: :cascade do |t|
    t.string   "name"
    t.integer  "c_type"
    t.text     "description"
    t.string   "photo"
    t.integer  "user_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "documents",   default: [],              array: true
    t.index ["user_id"], name: "index_communities_on_user_id", using: :btree
  end

  create_table "communities_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "community_id"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["community_id"], name: "index_communities_users_on_community_id", using: :btree
    t.index ["user_id"], name: "index_communities_users_on_user_id", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name",       limit: 200
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "confirm_skills", force: :cascade do |t|
    t.integer  "resume_skill_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "contract_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "departments", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "code"
    t.string   "name_ru"
    t.integer  "parent_id"
    t.integer  "region"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "legal_unit_id"
    t.integer  "manager_id"
    t.string   "logo"
    t.index ["company_id"], name: "index_departments_on_company_id", using: :btree
    t.index ["legal_unit_id"], name: "index_departments_on_legal_unit_id", using: :btree
    t.index ["parent_id"], name: "index_departments_on_parent_id", using: :btree
  end

  create_table "documents", force: :cascade do |t|
    t.string   "name"
    t.string   "file"
    t.integer  "document_attachable_id"
    t.string   "document_attachable_type"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "education_levels", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_participants", force: :cascade do |t|
    t.integer  "event_id"
    t.string   "email"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_participants_on_event_id", using: :btree
    t.index ["user_id"], name: "index_event_participants_on_user_id", using: :btree
  end

  create_table "event_types", force: :cascade do |t|
    t.string   "name"
    t.string   "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "description"
    t.integer  "event_type_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "place"
    t.integer  "created_by_id"
    t.index ["event_type_id"], name: "index_events_on_event_type_id", using: :btree
  end

  create_table "language_levels", force: :cascade do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "language_skills", force: :cascade do |t|
    t.integer  "resume_id"
    t.integer  "language_id"
    t.integer  "language_level_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["language_id"], name: "index_language_skills_on_language_id", using: :btree
    t.index ["language_level_id"], name: "index_language_skills_on_language_level_id", using: :btree
    t.index ["resume_id"], name: "index_language_skills_on_resume_id", using: :btree
  end

  create_table "languages", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legal_unit_employee_positions", force: :cascade do |t|
    t.string   "department_code"
    t.string   "position_code"
    t.date     "order_date"
    t.string   "order_number"
    t.string   "order_author"
    t.integer  "legal_unit_employee_id"
    t.integer  "transfer_type"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["legal_unit_employee_id"], name: "index_legal_unit_employee_positions_on_legal_unit_employee_id", using: :btree
  end

  create_table "legal_unit_employee_states", force: :cascade do |t|
    t.string   "state"
    t.datetime "changed_at"
    t.integer  "changed_by"
    t.string   "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legal_unit_employees", force: :cascade do |t|
    t.integer  "profile_id"
    t.integer  "legal_unit_id"
    t.boolean  "default"
    t.string   "employee_number"
    t.string   "employee_uid"
    t.string   "individual_employee_uid"
    t.string   "email_corporate"
    t.string   "email_work"
    t.string   "phone_corporate"
    t.string   "phone_work"
    t.date     "hired_at"
    t.integer  "legal_unit_employee_state_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "manager_id"
    t.integer  "office_id"
    t.float    "wage"
    t.float    "wage_rate"
    t.float    "pay"
    t.float    "extrapay"
    t.date     "contract_end_at"
    t.integer  "contract_type_id"
    t.string   "contract_id"
    t.string   "probation_period"
    t.date     "starts_work_at"
    t.index ["legal_unit_employee_state_id"], name: "index_legal_unit_employees_on_legal_unit_employee_state_id", using: :btree
    t.index ["legal_unit_id"], name: "index_legal_unit_employees_on_legal_unit_id", using: :btree
    t.index ["office_id"], name: "index_legal_unit_employees_on_office_id", using: :btree
    t.index ["profile_id"], name: "index_legal_unit_employees_on_profile_id", using: :btree
  end

  create_table "legal_units", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.string   "uuid"
    t.integer  "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "logo"
    t.index ["company_id"], name: "index_legal_units_on_company_id", using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.text     "body"
    t.integer  "topic_id"
    t.integer  "parent_message_id"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["parent_message_id"], name: "index_messages_on_parent_message_id", using: :btree
    t.index ["topic_id"], name: "index_messages_on_topic_id", using: :btree
    t.index ["user_id"], name: "index_messages_on_user_id", using: :btree
  end

  create_table "news_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "news_items", force: :cascade do |t|
    t.integer  "news_category_id"
    t.integer  "user_id"
    t.string   "state"
    t.string   "title"
    t.string   "preview"
    t.text     "body"
    t.boolean  "on_top"
    t.datetime "published_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "community_id"
    t.index ["news_category_id"], name: "index_news_items_on_news_category_id", using: :btree
    t.index ["user_id"], name: "index_news_items_on_user_id", using: :btree
  end

  create_table "notifications", force: :cascade do |t|
    t.string   "notice_type"
    t.integer  "notice_id"
    t.string   "body",        limit: 256
    t.boolean  "dispatch"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["notice_type", "notice_id"], name: "index_notifications_on_notice_type_and_notice_id", using: :btree
    t.index ["user_id"], name: "index_notifications_on_user_id", using: :btree
  end

  create_table "offices", force: :cascade do |t|
    t.string   "name",       limit: 200
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "code"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "photos", force: :cascade do |t|
    t.string   "name"
    t.string   "file"
    t.integer  "photo_attachable_id"
    t.string   "photo_attachable_type"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "position_groups", force: :cascade do |t|
    t.string   "code"
    t.string   "name_ru"
    t.text     "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "legal_unit_id"
    t.index ["legal_unit_id"], name: "index_position_groups_on_legal_unit_id", using: :btree
  end

  create_table "positions", force: :cascade do |t|
    t.string   "code"
    t.string   "name_ru"
    t.text     "description"
    t.string   "position_group_code"
    t.integer  "salary_from"
    t.integer  "salary_up"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "legal_unit_id"
    t.index ["legal_unit_id"], name: "index_positions_on_legal_unit_id", using: :btree
    t.index ["position_group_code"], name: "index_positions_on_position_group_code", using: :btree
  end

  create_table "professional_areas", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "professional_specializations", force: :cascade do |t|
    t.integer  "professional_area_id"
    t.string   "name"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["professional_area_id"], name: "index_professional_specializations_on_professional_area_id", using: :btree
  end

  create_table "professional_specializations_resumes", force: :cascade do |t|
    t.integer "resume_id"
    t.integer "professional_specialization_id"
    t.index ["professional_specialization_id"], name: "index_professional_specializations_resumes_on_prof_spec_id", using: :btree
    t.index ["resume_id"], name: "index_professional_specializations_resumes_on_resume_id", using: :btree
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "password",             limit: 100
    t.string   "surname",              limit: 100
    t.string   "name",                 limit: 100
    t.string   "middlename",           limit: 100
    t.string   "photo",                limit: 200
    t.date     "birthday"
    t.string   "email_private",        limit: 100
    t.string   "phone_number_private", limit: 20
    t.string   "skype",                limit: 100
    t.string   "telegram",             limit: 200
    t.string   "vk_url",               limit: 200
    t.string   "fb_url",               limit: 200
    t.string   "linkedin_url",         limit: 200
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "sex"
    t.string   "city"
  end

  create_table "project_roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "title",         limit: 300
    t.string   "description",   limit: 1000
    t.integer  "manager"
    t.integer  "customer_id"
    t.date     "begin_date"
    t.date     "end_date"
    t.string   "status",        limit: 30
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "legal_unit_id"
    t.string   "charge_code"
    t.index ["legal_unit_id"], name: "index_projects_on_legal_unit_id", using: :btree
  end

  create_table "resume_certificates", force: :cascade do |t|
    t.string   "name",         limit: 200
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "resume_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "company_name"
  end

  create_table "resume_educations", force: :cascade do |t|
    t.string   "school_name"
    t.string   "faculty_name"
    t.string   "speciality"
    t.integer  "end_year"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "resume_experiences", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "position",   limit: 100
    t.date     "start_date"
    t.date     "end_date"
    t.string   "tasks",      limit: 500
    t.integer  "resume_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "resume_recommendations", force: :cascade do |t|
    t.integer  "resume_id"
    t.string   "recommender_name"
    t.string   "company_and_position"
    t.string   "phone"
    t.string   "email"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["resume_id"], name: "index_resume_recommendations_on_resume_id", using: :btree
  end

  create_table "resume_skills", force: :cascade do |t|
    t.integer  "resume_id"
    t.integer  "skill_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "resume_work_experiences", force: :cascade do |t|
    t.integer  "resume_id"
    t.string   "position"
    t.string   "company_name"
    t.string   "region"
    t.string   "website"
    t.date     "start_date"
    t.date     "end_date"
    t.text     "experience_description"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["resume_id"], name: "index_resume_work_experiences_on_resume_id", using: :btree
  end

  create_table "resumes", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "position"
    t.string   "city"
    t.string   "phone"
    t.string   "email"
    t.string   "skype"
    t.integer  "preferred_contact_type"
    t.date     "birthdate"
    t.string   "photo"
    t.integer  "sex"
    t.integer  "martial_condition"
    t.integer  "have_children"
    t.text     "skills_description"
    t.string   "desired_position"
    t.integer  "salary_level"
    t.json     "employment_type"
    t.json     "working_schedule"
    t.text     "comment"
    t.json     "documents"
    t.integer  "professional_specialization_id"
    t.integer  "education_level_id"
    t.json     "experience"
    t.index ["education_level_id"], name: "index_resumes_on_education_level_id", using: :btree
    t.index ["professional_specialization_id"], name: "index_resumes_on_professional_specialization_id", using: :btree
  end

  create_table "role_functions", force: :cascade do |t|
    t.integer  "role_id"
    t.string   "module_code",   limit: 100
    t.string   "function_code"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["role_id"], name: "index_role_functions_on_role_id", using: :btree
  end

  create_table "role_permissions", force: :cascade do |t|
    t.integer  "role_id"
    t.integer  "permission_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id", using: :btree
    t.index ["role_id"], name: "index_role_permissions_on_role_id", using: :btree
  end

  create_table "role_rights", force: :cascade do |t|
    t.integer  "role_id"
    t.string   "module_code", limit: 100
    t.string   "object_code", limit: 100
    t.string   "group_code",  limit: 20
    t.integer  "rights"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["role_id"], name: "index_role_rights_on_role_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 50
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "skills", force: :cascade do |t|
    t.string   "name",       limit: 50
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_type"
    t.integer  "taggable_id"
    t.string   "tagger_type"
    t.integer  "tagger_id"
    t.string   "context",       limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context", using: :btree
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true, using: :btree
  end

  create_table "topics", force: :cascade do |t|
    t.string   "subject",      limit: 70
    t.string   "photo"
    t.integer  "community_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["community_id"], name: "index_topics_on_community_id", using: :btree
  end

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "project_role_id"
    t.date     "start_date"
    t.date     "end_date"
    t.json     "skills"
    t.text     "duties"
    t.text     "feedback"
    t.integer  "rating"
    t.integer  "worked_hours"
    t.index ["project_role_id"], name: "index_user_projects_on_project_role_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "status",                 limit: 15
    t.string   "email",                             default: "",      null: false
    t.string   "encrypted_password",                default: "",      null: false
    t.string   "provider",                          default: "email", null: false
    t.string   "uid",                               default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.json     "tokens"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "role_id"
    t.integer  "company_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role_id"], name: "index_users_on_role_id", using: :btree
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "comments", "users"
  add_foreign_key "communities", "users"
  add_foreign_key "communities_users", "communities"
  add_foreign_key "communities_users", "users"
  add_foreign_key "departments", "companies"
  add_foreign_key "departments", "legal_units"
  add_foreign_key "event_participants", "events"
  add_foreign_key "event_participants", "users"
  add_foreign_key "events", "event_types"
  add_foreign_key "language_skills", "language_levels"
  add_foreign_key "language_skills", "languages"
  add_foreign_key "language_skills", "resumes"
  add_foreign_key "legal_unit_employee_positions", "legal_unit_employees"
  add_foreign_key "legal_unit_employees", "legal_unit_employee_states"
  add_foreign_key "legal_unit_employees", "legal_units"
  add_foreign_key "legal_unit_employees", "profiles"
  add_foreign_key "legal_unit_employees", "profiles", column: "manager_id"
  add_foreign_key "legal_units", "companies"
  add_foreign_key "messages", "topics"
  add_foreign_key "messages", "users"
  add_foreign_key "news_items", "news_categories"
  add_foreign_key "news_items", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "position_groups", "legal_units"
  add_foreign_key "positions", "legal_units"
  add_foreign_key "professional_specializations", "professional_areas"
  add_foreign_key "professional_specializations_resumes", "professional_specializations"
  add_foreign_key "professional_specializations_resumes", "resumes"
  add_foreign_key "projects", "legal_units"
  add_foreign_key "resume_recommendations", "resumes"
  add_foreign_key "resume_work_experiences", "resumes"
  add_foreign_key "role_functions", "roles"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "role_rights", "roles"
  add_foreign_key "topics", "communities"
  add_foreign_key "user_projects", "project_roles"
  add_foreign_key "users", "roles"
end
