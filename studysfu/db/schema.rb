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

ActiveRecord::Schema.define(version: 20151125102317) do

  create_table "associated_classes", force: :cascade do |t|
    t.integer  "number"
    t.integer  "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "associated_classes", ["course_id"], name: "index_associated_classes_on_course_id"
  add_index "associated_classes", ["number", "course_id"], name: "index_associated_classes_on_number_and_course_id", unique: true

  create_table "comments", force: :cascade do |t|
    t.integer  "link_id"
    t.text     "body",       null: false
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "comments", ["link_id"], name: "index_comments_on_link_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "department_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "courses", ["department_id"], name: "index_courses_on_department_id"
  add_index "courses", ["number", "department_id"], name: "index_courses_on_number_and_department_id", unique: true

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.integer  "term_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "departments", ["name", "term_id"], name: "index_departments_on_name_and_term_id", unique: true
  add_index "departments", ["term_id"], name: "index_departments_on_term_id"

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "all_day"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exams", force: :cascade do |t|
    t.string   "building"
    t.string   "room"
    t.string   "campus"
    t.datetime "exam_start"
    t.datetime "exam_end"
    t.integer  "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "exams", ["section_id"], name: "index_exams_on_section_id"

  create_table "instructors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "office"
    t.string   "office_hours"
    t.string   "phone"
    t.string   "website"
    t.integer  "section_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "instructors", ["section_id"], name: "index_instructors_on_section_id"

  create_table "links", force: :cascade do |t|
    t.string   "title",      null: false
    t.string   "department", null: false
    t.string   "course",     null: false
    t.text     "body",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.string   "attachment"
  end

  add_index "links", ["user_id"], name: "index_links_on_user_id"

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.string   "url"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"

  create_table "resumelists", force: :cascade do |t|
    t.text     "content"
    t.string   "section"
    t.date     "start"
    t.date     "finish"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "resumelists", ["user_id", "created_at"], name: "index_resumelists_on_user_id_and_created_at"
  add_index "resumelists", ["user_id"], name: "index_resumelists_on_user_id"

  create_table "section_times", force: :cascade do |t|
    t.string   "building"
    t.string   "room"
    t.string   "campus"
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.string   "days"
    t.integer  "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "section_times", ["section_id"], name: "index_section_times_on_section_id"

  create_table "sections", force: :cascade do |t|
    t.string   "unique_number"
    t.string   "key"
    t.string   "code"
    t.integer  "associated_class_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "sections", ["associated_class_id"], name: "index_sections_on_associated_class_id"
  add_index "sections", ["key", "associated_class_id"], name: "index_sections_on_key_and_associated_class_id", unique: true

  create_table "terms", force: :cascade do |t|
    t.string   "name"
    t.integer  "year_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "terms", ["name", "year_id"], name: "index_terms_on_name_and_year_id", unique: true
  add_index "terms", ["year_id"], name: "index_terms_on_year_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "firstName"
    t.string   "lastName"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.boolean  "admin",             default: false
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "votes", force: :cascade do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"

  create_table "years", force: :cascade do |t|
    t.string   "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
