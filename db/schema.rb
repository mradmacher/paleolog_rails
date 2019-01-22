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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190122211840) do

  create_table "choices", force: :cascade do |t|
    t.string  "name"
    t.integer "field_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "message"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countings", force: :cascade do |t|
    t.string  "name"
    t.integer "group_id"
    t.integer "marker_id"
    t.integer "marker_count"
    t.integer "project_id"
  end

  add_index "countings", ["project_id"], name: "index_countings_on_project_id"

  create_table "dinos", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "features", force: :cascade do |t|
    t.integer "specimen_id"
    t.integer "choice_id"
  end

  create_table "fields", force: :cascade do |t|
    t.string  "name"
    t.integer "group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "specimen_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "sample_id"
    t.string   "ef"
  end

  create_table "occurrences", force: :cascade do |t|
    t.integer "specimen_id"
    t.integer "quantity"
    t.integer "rank"
    t.integer "status",      default: 0
    t.boolean "uncertain",   default: false
    t.integer "sample_id"
    t.integer "counting_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "research_participations", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "manager",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "project_id"
  end

  add_index "research_participations", ["project_id"], name: "index_research_participations_on_project_id"

  create_table "sample_specimens", force: :cascade do |t|
    t.integer "specimen_id"
    t.string  "specimen_type"
    t.integer "sample_id"
    t.integer "quantity"
  end

  create_table "samples", force: :cascade do |t|
    t.string   "name"
    t.integer  "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "bottom_depth"
    t.decimal  "top_depth"
    t.text     "description"
    t.decimal  "weight"
  end

  create_table "sections", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "specimens", force: :cascade do |t|
    t.string   "name"
    t.boolean  "verified"
    t.text     "description"
    t.text     "environmental_preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.boolean  "admin",      default: false
  end

end
