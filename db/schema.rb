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

ActiveRecord::Schema.define(version: 20170608210002) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comptes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.date     "date"
    t.integer  "cpS_id"
    t.integer  "cpD_id"
    t.string   "com"
    t.integer  "pr"
    t.boolean  "poS"
    t.boolean  "poD"
    t.integer  "moyen_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_entries_on_category_id"
    t.index ["cpD_id"], name: "index_entries_on_cpD_id"
    t.index ["cpS_id"], name: "index_entries_on_cpS_id"
    t.index ["moyen_id"], name: "index_entries_on_moyen_id"
  end

  create_table "moyens", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "periodics", force: :cascade do |t|
    t.date     "lastdate"
    t.integer  "cpS_id"
    t.integer  "cpD_id"
    t.string   "com"
    t.integer  "pr"
    t.integer  "days"
    t.integer  "months"
    t.integer  "moyen_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_periodics_on_category_id"
    t.index ["cpD_id"], name: "index_periodics_on_cpD_id"
    t.index ["cpS_id"], name: "index_periodics_on_cpS_id"
    t.index ["moyen_id"], name: "index_periodics_on_moyen_id"
  end

end
