# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20151123192526) do

  create_table "actions", :force => true do |t|
    t.integer  "rule_id",          :null => false
    t.integer  "display_field_id", :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value_type"
    t.integer  "clone_of_id"
  end

  add_index "actions", ["rule_id"], :name => "index_actions_on_rule_id"

  create_table "assets", :force => true do |t|
    t.text     "snippet"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "choice_answers", :force => true do |t|
    t.string   "answer"
    t.integer  "choice_question_id"
    t.integer  "answer_order"
    t.integer  "next_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clone_of_id"
    t.boolean  "is_default",         :default => false
  end

  add_index "choice_answers", ["choice_question_id"], :name => "answers_choice_question_id"

  create_table "choice_questions", :force => true do |t|
    t.boolean  "multiselect"
    t.string   "answer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "matrix_question_id"
    t.integer  "clone_of_id"
    t.boolean  "auto_next_page"
    t.boolean  "display_results"
    t.boolean  "answer_placement"
  end

  create_table "conditionals", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "criteria", :force => true do |t|
    t.integer  "rule_id",        :null => false
    t.integer  "source_id",      :null => false
    t.integer  "conditional_id", :null => false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type",    :null => false
    t.integer  "clone_of_id"
  end

  add_index "criteria", ["conditional_id"], :name => "index_criteria_conditional_id"
  add_index "criteria", ["rule_id"], :name => "index_criteria_on_rule_id"
  add_index "criteria", ["source_id"], :name => "index_criteria_on_source_id"

  create_table "custom_views", :force => true do |t|
    t.integer  "survey_version_id"
    t.string   "name"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_views", ["survey_version_id"], :name => "index_custom_views_on_survey_version_id"

  create_table "dashboard_elements", :force => true do |t|
    t.integer  "dashboard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_element_id"
    t.integer  "sort_order"
    t.string   "display_type"
  end

  add_index "dashboard_elements", ["survey_element_id"], :name => "index_dashboard_elements_on_survey_element_id"

  create_table "dashboards", :force => true do |t|
    t.string   "name"
    t.integer  "survey_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "display_field_categories", :force => true do |t|
    t.integer  "display_field_id", :null => false
    t.integer  "category_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "display_field_categories", ["display_field_id"], :name => "index_dfc_on_display_field_id"

  create_table "display_field_custom_views", :force => true do |t|
    t.integer  "display_field_id"
    t.integer  "custom_view_id"
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_order"
    t.string   "sort_direction"
  end

  add_index "display_field_custom_views", ["custom_view_id"], :name => "index_display_field_custom_views_on_custom_view_id"
  add_index "display_field_custom_views", ["display_field_id"], :name => "index_display_field_custom_views_on_display_field_id"

  create_table "display_field_values", :force => true do |t|
    t.integer  "display_field_id",   :null => false
    t.integer  "survey_response_id", :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "display_field_values", ["display_field_id"], :name => "index_dfv_on_display_field_id"
  add_index "display_field_values", ["survey_response_id"], :name => "index_dfv_survey_response_id"

  create_table "display_fields", :force => true do |t|
    t.string   "name",                                 :null => false
    t.string   "type",                                 :null => false
    t.boolean  "required",          :default => false
    t.boolean  "searchable",        :default => false
    t.string   "default_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_order",                        :null => false
    t.integer  "survey_version_id"
    t.integer  "clone_of_id"
    t.string   "choices"
    t.boolean  "editable",          :default => true
  end

  add_index "display_fields", ["survey_version_id"], :name => "index_dfs_survey_version_id"

  create_table "email_actions", :force => true do |t|
    t.string   "emails"
    t.string   "subject"
    t.text     "body"
    t.integer  "rule_id"
    t.integer  "clone_of_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "execution_trigger_rules", :force => true do |t|
    t.integer  "rule_id",              :null => false
    t.integer  "execution_trigger_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "execution_triggers", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exports", :force => true do |t|
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "survey_version_id"
  end

  create_table "matrix_questions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_version_id"
    t.integer  "clone_of_id"
  end

  create_table "new_responses", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_response_id"
  end

  add_index "new_responses", ["survey_response_id"], :name => "index_nrs_survey_response_id"

  create_table "pages", :force => true do |t|
    t.integer  "page_number"
    t.integer  "survey_version_id"
    t.integer  "style_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clone_of_id"
    t.integer  "next_page_id"
  end

  add_index "pages", ["survey_version_id"], :name => "index_pages_survey_version_id"

  create_table "question_bank_questions", :force => true do |t|
    t.integer  "question_bank_id"
    t.integer  "bankable_id"
    t.string   "bankable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_banks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_content_display_fields", :force => true do |t|
    t.integer  "question_content_id"
    t.integer  "display_field_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_contents", :force => true do |t|
    t.string   "statement"
    t.string   "questionable_type"
    t.integer  "questionable_id"
    t.boolean  "flow_control"
    t.boolean  "required",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_contents", ["questionable_id", "questionable_type"], :name => "index_qcs_questionable"

  create_table "raw_responses", :force => true do |t|
    t.string   "client_id"
    t.text     "answer"
    t.integer  "question_content_id"
    t.integer  "status_id",           :default => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "worker_name"
    t.integer  "survey_response_id",                 :null => false
  end

  add_index "raw_responses", ["client_id"], :name => "index_rr_client_id"
  add_index "raw_responses", ["question_content_id"], :name => "index_rr_question_content_id"
  add_index "raw_responses", ["status_id"], :name => "index_rr_status_id"
  add_index "raw_responses", ["survey_response_id"], :name => "index_rr_survey_response_id"

  create_table "raw_submissions", :force => true do |t|
    t.string   "uuid_key"
    t.integer  "survey_id"
    t.integer  "survey_version_id"
    t.text     "post",              :limit => 16777215
    t.boolean  "submitted",                             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "raw_submissions", ["uuid_key"], :name => "uuid_key"

  create_table "recurring_reports", :force => true do |t|
    t.integer  "report_id"
    t.integer  "user_created_by_id"
    t.string   "user_created_by_string"
    t.integer  "user_last_modified_by_id"
    t.string   "frequency"
    t.integer  "day_of_week"
    t.integer  "day_of_month"
    t.integer  "month"
    t.string   "emails",                   :limit => 1000
    t.boolean  "pdf"
    t.datetime "last_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_elements", :force => true do |t|
    t.string   "type"
    t.integer  "report_id"
    t.integer  "choice_question_id"
    t.integer  "text_question_id"
    t.integer  "matrix_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.integer  "survey_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "limit_answers",     :default => false
  end

  create_table "response_categories", :force => true do |t|
    t.integer  "category_id",         :null => false
    t.integer  "process_response_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_version_id",   :null => false
  end

  create_table "resqued_jobs", :force => true do |t|
    t.string   "class_name"
    t.text     "job_arguments", :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", :force => true do |t|
    t.string   "name",                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_version_id",                   :null => false
    t.integer  "rule_order",                          :null => false
    t.integer  "clone_of_id"
    t.string   "action_type",       :default => "db"
  end

  add_index "rules", ["survey_version_id"], :name => "index_rules_survey_version_id"

  create_table "saved_searches", :force => true do |t|
    t.string   "name"
    t.integer  "survey_version_id"
    t.text     "search_params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_users", :force => true do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "statuses", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_elements", :force => true do |t|
    t.integer  "page_id"
    t.integer  "element_order"
    t.integer  "assetable_id"
    t.string   "assetable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "survey_version_id"
  end

  add_index "survey_elements", ["assetable_id", "assetable_type"], :name => "index_elements_assetable"
  add_index "survey_elements", ["page_id"], :name => "survey_elements_page_id"

  create_table "survey_responses", :force => true do |t|
    t.string   "client_id"
    t.integer  "survey_version_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",         :default => 1,         :null => false
    t.datetime "last_processed"
    t.string   "worker_name"
    t.text     "page_url"
    t.boolean  "archived",          :default => false
    t.string   "device",            :default => "Desktop"
  end

  add_index "survey_responses", ["status_id"], :name => "index_srs_status_id"
  add_index "survey_responses", ["survey_version_id"], :name => "index_srs_survey_version_id"

  create_table "survey_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_version_counts", :force => true do |t|
    t.integer  "survey_version_id"
    t.date     "count_date"
    t.integer  "visits",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "questions_skipped",    :default => 0
    t.integer  "questions_asked",      :default => 0
    t.integer  "invitations",          :default => 0
    t.integer  "invitations_accepted", :default => 0
  end

  add_index "survey_version_counts", ["survey_version_id", "count_date"], :name => "index_survey_visit_counts_on_survey_version_id_and_visit_date", :unique => true
  add_index "survey_version_counts", ["survey_version_id"], :name => "index_survey_visit_counts_on_survey_version_id"

  create_table "survey_versions", :force => true do |t|
    t.integer  "survey_id",                            :null => false
    t.integer  "major"
    t.integer  "minor"
    t.boolean  "published",         :default => false
    t.boolean  "locked",            :default => false
    t.boolean  "archived",          :default => false
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "thank_you_page"
    t.datetime "counts_updated_at"
    t.boolean  "dirty_reports"
    t.integer  "created_by_id"
  end

  add_index "survey_versions", ["survey_id"], :name => "index_versions_on_survey_id"

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "survey_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",                      :default => false
    t.integer  "site_id"
    t.string   "submit_button_text"
    t.string   "previous_page_text"
    t.string   "next_page_text"
    t.string   "js_required_fields_error"
    t.integer  "invitation_percent",            :default => 100,   :null => false
    t.integer  "invitation_interval",           :default => 30,    :null => false
    t.text     "invitation_text"
    t.string   "invitation_accept_button_text"
    t.string   "invitation_reject_button_text"
    t.boolean  "alarm"
    t.string   "alarm_notification_email"
    t.text     "holding_page"
    t.boolean  "show_numbers",                  :default => true
    t.string   "locale"
    t.string   "start_screen_button_text"
    t.string   "start_page_title"
    t.string   "invitation_preview_stylesheet"
    t.string   "survey_preview_stylesheet"
    t.string   "omb_expiration_date"
  end

  create_table "text_questions", :force => true do |t|
    t.string   "answer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clone_of_id"
    t.integer  "row_size"
    t.integer  "column_size"
    t.integer  "answer_size"
  end

  create_table "users", :force => true do |t|
    t.string   "f_name",                          :null => false
    t.string   "l_name",                          :null => false
    t.boolean  "locked"
    t.string   "email",                           :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.string   "hhs_id",            :limit => 50
    t.datetime "last_request_at"
    t.string   "fullname"
  end

end
