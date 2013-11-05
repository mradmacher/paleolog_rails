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

ActiveRecord::Schema.define(:version => 20130705222258) do

  create_table "choices", :force => true do |t|
    t.string  "name"
    t.integer "field_id"
  end

  create_table "comments", :force => true do |t|
    t.string   "message"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countings", :force => true do |t|
    t.string  "name"
    t.integer "well_id"
    t.integer "group_id"
    t.integer "marker_id"
    t.integer "marker_count"
  end

  create_table "features", :force => true do |t|
    t.integer "specimen_id"
    t.integer "choice_id"
  end

  create_table "fields", :force => true do |t|
    t.string  "name"
    t.integer "group_id"
  end

  create_table "groups", :force => true do |t|
    t.string "name"
  end

  create_table "images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "specimen_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "sample_id"
    t.string   "ef"
  end

  create_table "occurrences", :force => true do |t|
    t.integer "specimen_id"
    t.string  "specimen_type"
    t.integer "quantity"
    t.integer "sample_counting_id"
    t.integer "rank"
    t.integer "status",             :default => 0
    t.boolean "uncertain",          :default => false
    t.integer "sample_id"
    t.integer "counting_id"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "research_participations", :force => true do |t|
    t.integer  "well_id"
    t.integer  "user_id"
    t.boolean  "manager",    :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "samples", :force => true do |t|
    t.string   "name"
    t.integer  "well_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "bottom_depth"
    t.decimal  "top_depth"
    t.text     "description"
    t.decimal  "weight"
  end

  create_table "specimens", :force => true do |t|
    t.string   "name"
    t.boolean  "verified"
    t.text     "description"
    t.text     "age"
    t.text     "comparison"
    t.text     "range"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login"
    t.boolean  "admin",      :default => false
  end

  create_table "wells", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "region_id"
  end

end
