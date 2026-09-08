# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_07_193000) do
  create_table "birthdays", force: :cascade do |t|
    t.text "body", default: "", null: false
    t.datetime "created_at", null: false
    t.integer "day", null: false
    t.integer "month", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "year"
    t.index ["user_id", "month", "day"], name: "index_birthdays_on_user_id_and_month_and_day"
    t.index ["user_id"], name: "index_birthdays_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "all_day", default: true, null: false
    t.text "body", default: "", null: false
    t.datetime "created_at", null: false
    t.time "ends_at"
    t.date "ends_on", null: false
    t.time "starts_at"
    t.date "starts_on", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id", "ends_on"], name: "index_events_on_user_id_and_ends_on"
    t.index ["user_id", "starts_on"], name: "index_events_on_user_id_and_starts_on"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "holiday_countries", default: "BR", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "birthdays", "users"
  add_foreign_key "events", "users"
end
