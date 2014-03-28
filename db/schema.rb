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

ActiveRecord::Schema.define(version: 20140327084825) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alternatives", force: true do |t|
    t.string  "name",                      null: false
    t.integer "reviews_count", default: 0, null: false
  end

  create_table "alternatives_criteria", id: false, force: true do |t|
    t.integer "alternative_id"
    t.integer "criterion_id"
    t.integer "rating"
    t.integer "reviews_count",  default: 0, null: false
  end

  add_index "alternatives_criteria", ["alternative_id"], name: "index_alternatives_criteria_on_alternative_id", using: :btree
  add_index "alternatives_criteria", ["criterion_id", "alternative_id"], name: "index_alternatives_criteria_on_criterion_id_and_alternative_id", unique: true, using: :btree

  create_table "criteria", force: true do |t|
    t.string  "name",                    null: false
    t.string  "short_name"
    t.string  "description"
    t.integer "status",      default: 0, null: false
    t.string  "ancestry"
  end

  add_index "criteria", ["ancestry"], name: "index_criteria_on_ancestry", using: :btree

  create_table "media", force: true do |t|
    t.integer  "alternative_id"
    t.string   "type"
    t.string   "agency_id"
    t.string   "url"
    t.string   "medium_type"
    t.boolean  "cover"
    t.integer  "status",         default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "media", ["alternative_id"], name: "index_media_on_alternative_id", using: :btree

  create_table "property_fields", force: true do |t|
    t.integer  "group_id"
    t.string   "field_type",             null: false
    t.string   "name",                   null: false
    t.string   "title",                  null: false
    t.integer  "status",     default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "property_fields", ["group_id"], name: "index_property_fields_on_group_id", using: :btree

  create_table "property_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "property_values", force: true do |t|
    t.integer  "alternative_id"
    t.integer  "field_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "property_values", ["alternative_id"], name: "index_property_values_on_alternative_id", using: :btree
  add_index "property_values", ["field_id"], name: "index_property_values_on_field_id", using: :btree

  create_table "review_sentences", force: true do |t|
    t.integer  "alternative_id"
    t.integer  "criterion_id"
    t.integer  "review_id"
    t.json     "sentences"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "review_sentences", ["alternative_id"], name: "index_review_sentences_on_alternative_id", using: :btree
  add_index "review_sentences", ["criterion_id"], name: "index_review_sentences_on_criterion_id", using: :btree
  add_index "review_sentences", ["review_id"], name: "index_review_sentences_on_review_id", using: :btree

  create_table "reviews", force: true do |t|
    t.integer "alternative_id"
    t.text    "body"
    t.date    "date"
    t.string  "type"
    t.integer "agency_id"
  end

  add_index "reviews", ["alternative_id"], name: "index_reviews_on_alternative_id", using: :btree
  add_index "reviews", ["type", "agency_id"], name: "index_reviews_on_type_and_agency_id", using: :btree

end
