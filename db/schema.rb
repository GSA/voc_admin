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

ActiveRecord::Schema.define(:version => 20110413183938) do

  create_table "choice_answers", :force => true do |t|
    t.string   "answer"
    t.integer  "choice_question_id"
    t.integer  "answer_order"
    t.integer  "next_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "choice_questions", :force => true do |t|
    t.boolean  "multiselect"
    t.string   "answer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "number"
    t.integer  "survey_version_id"
    t.integer  "style_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_contents", :force => true do |t|
    t.string   "name"
    t.string   "statement"
    t.integer  "number"
    t.string   "questionable_type"
    t.integer  "questionable_id"
    t.integer  "display_id"
    t.boolean  "flow_control"
    t.boolean  "required",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "raw_responses", :force => true do |t|
    t.integer  "survey_version_id"
    t.string   "client_id"
    t.text     "answer"
    t.integer  "question_id"
    t.integer  "status_id"
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

  create_table "survey_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "survey_versions", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "major"
    t.integer  "minor"
    t.boolean  "published"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "survey_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "text_questions", :force => true do |t|
    t.string   "answer_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
