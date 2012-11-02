class InitialMigration < ActiveRecord::Migration
  def self.up
    create_table "actions", :force => true do |t|
      t.integer  "rule_id",          :null => false
      t.integer  "display_field_id", :null => false
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "value_type"
    end

    add_index "actions", ["rule_id"], :name => "index_actions_on_rule_id"
    add_index :actions, :display_field_id

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
    end

    add_index "choice_answers", ["choice_question_id"], :name => "answers_choice_question_id"
    add_index :choice_answers, :next_page_id

    create_table "choice_questions", :force => true do |t|
      t.boolean  "multiselect"
      t.string   "answer_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "matrix_question_id"
    end

    add_index :choice_questions, :matrix_question_id

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
    end

    add_index "criteria", ["rule_id"], :name => "index_criteria_on_rule_id"
    add_index "criteria", ["source_id"], :name => "index_criteria_on_source_id"
    add_index "criteria", ["conditional_id"], :name => "index_criteria_conditional_id"
    add_index :criteria, [:source_id, :source_type]

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
    end

    add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

    create_table "display_field_categories", :force => true do |t|
      t.integer  "display_field_id", :null => false
      t.integer  "category_id",      :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "display_field_categories", "display_field_id", :name => "index_dfc_on_display_field_id"
    add_index :display_field_categories, :category_id

    create_table "display_field_values", :force => true do |t|
      t.integer  "display_field_id",   :null => false
      t.integer  "survey_response_id", :null => false
      t.string   "value"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "display_field_values", "display_field_id", :name => "index_dfv_on_display_field_id"
    add_index "display_field_values", "survey_response_id", :name => "index_dfv_survey_response_id"

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
    end

    add_index "display_fields", "survey_version_id", :name => "index_dfs_survey_version_id"

    create_table "execution_trigger_rules", :force => true do |t|
      t.integer  "rule_id",              :null => false
      t.integer  "execution_trigger_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index :execution_trigger_rules, :execution_trigger_id
    add_index :execution_trigger_rules, :rule_id

    create_table "execution_triggers", :force => true do |t|
      t.string   "name",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "matrix_questions", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "survey_version_id"
    end

    add_index :matrix_questions, :survey_version_id

    create_table "new_responses", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "survey_response_id"
    end

    add_index "new_responses", "survey_response_id", :name => "index_nrs_survey_response_id"

    create_table "pages", :force => true do |t|
      t.integer  "page_number"
      t.integer  "survey_version_id"
      t.integer  "style_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "pages", "survey_version_id", :name => "index_pages_survey_version_id"

    create_table "question_contents", :force => true do |t|
      t.string   "statement"
      t.string   "questionable_type"
      t.integer  "questionable_id"
#      t.integer  "display_id"
      t.boolean  "flow_control"
      t.boolean  "required",          :default => true
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

    add_index "raw_responses", "client_id", :name => "index_rr_client_id"
    add_index "raw_responses", "question_content_id", :name => "index_rr_question_content_id"
    add_index "raw_responses", "status_id", :name => "index_rr_status_id"
    add_index "raw_responses", "survey_response_id", :name => "index_rr_survey_response_id"

    create_table "response_categories", :force => true do |t|
      t.integer  "category_id",         :null => false
      t.integer  "process_response_id", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "survey_version_id",   :null => false
    end

    add_index :response_categories, :category_id
    add_index :response_categories, :survey_version_id

    create_table "rules", :force => true do |t|
      t.string   "name",              :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "survey_version_id", :null => false
      t.integer  "rule_order",        :null => false
    end

    add_index "rules", "survey_version_id", :name => "index_rules_survey_version_id"

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
    add_index "survey_elements", "page_id", :name => "survey_elements_page_id"
    add_index :survey_elements, :survey_version_id

    create_table "survey_responses", :force => true do |t|
      t.string   "client_id"
      t.integer  "survey_version_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "status_id",         :default => 1, :null => false
      t.datetime "last_processed"
      t.string   "worker_name"
    end

    add_index "survey_responses", "status_id", :name => "index_srs_status_id"
    add_index "survey_responses", "survey_version_id", :name => "index_srs_survey_version_id"

    create_table "survey_types", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "survey_versions", :force => true do |t|
      t.integer  "survey_id",   :null => false
      t.integer  "major"
      t.integer  "minor"
      t.boolean  "published",   :default => false
      t.boolean  "locked",      :default => false
      t.boolean  "archived",    :default => false
      t.text     "notes"
      t.datetime "created_at"
      t.datetime "updated_at"

    end

    add_index "survey_versions", ["survey_id"], :name => "index_versions_on_survey_id"

    create_table "surveys", :force => true do |t|
      t.string   "name"
      t.text     "description"
      t.integer  "survey_type_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "archived",       :default => false
    end

    add_index "surveys", :survey_type_id

    create_table "text_questions", :force => true do |t|
      t.string   "answer_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
