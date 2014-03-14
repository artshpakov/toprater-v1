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

ActiveRecord::Schema.define(version: 20140314105834) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alternatives", force: true do |t|
    t.string "name", null: false
  end

  create_table "alternatives_criteria", id: false, force: true do |t|
    t.integer "alternative_id"
    t.integer "criterion_id"
    t.integer "rating"
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

end
