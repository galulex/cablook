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

ActiveRecord::Schema.define(version: 20180206152114) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bonus_trips", force: :cascade do |t|
    t.integer "status", default: 0
    t.bigint "user_id"
    t.bigint "friend_id"
    t.bigint "trip_id"
    t.string "code"
    t.index ["friend_id"], name: "index_bonus_trips_on_friend_id"
    t.index ["trip_id"], name: "index_bonus_trips_on_trip_id"
    t.index ["user_id"], name: "index_bonus_trips_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "token"
    t.string "pan"
    t.string "type"
    t.string "currency"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "number"
    t.integer "status", default: 0
    t.string "color"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.string "encrypted_password"
    t.string "auth_token"
    t.bigint "car_id"
    t.index ["car_id"], name: "index_drivers_on_car_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer "rate", default: 0
    t.text "description"
    t.bigint "trip_id"
    t.bigint "user_id"
    t.index ["trip_id"], name: "index_feedbacks_on_trip_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.integer "status", default: 0
    t.bigint "card_id"
    t.bigint "trip_id"
    t.bigint "driver_id"
    t.string "order_reference"
    t.bigint "user_id"
    t.index ["card_id"], name: "index_payments_on_card_id"
    t.index ["driver_id"], name: "index_payments_on_driver_id"
    t.index ["trip_id"], name: "index_payments_on_trip_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "trip_jobs", force: :cascade do |t|
    t.string "activejob_id"
    t.string "sidekiq_id"
    t.bigint "trip_id"
    t.index ["trip_id"], name: "index_trip_jobs_on_trip_id"
  end

  create_table "trips", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "path"
    t.integer "cost"
    t.text "departure", default: [], array: true
    t.text "destination", default: [], array: true
    t.string "departure_address"
    t.string "destination_address"
    t.datetime "estimated_end_time"
    t.bigint "car_id"
    t.bigint "driver_id"
    t.bigint "user_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.integer "distance"
    t.integer "duration"
    t.datetime "start_at"
    t.datetime "finish_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "arrived_at"
    t.index ["car_id"], name: "index_trips_on_car_id"
    t.index ["driver_id"], name: "index_trips_on_driver_id"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "encrypted_password"
    t.string "auth_token"
    t.string "verification_token"
    t.string "confirmation_token"
    t.string "referral_code"
  end

  add_foreign_key "bonus_trips", "trips"
  add_foreign_key "bonus_trips", "users"
  add_foreign_key "bonus_trips", "users", column: "friend_id"
  add_foreign_key "cards", "users"
  add_foreign_key "drivers", "cars"
  add_foreign_key "feedbacks", "trips"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "payments", "cards"
  add_foreign_key "payments", "drivers"
  add_foreign_key "payments", "trips"
  add_foreign_key "trip_jobs", "trips"
  add_foreign_key "trips", "cars"
  add_foreign_key "trips", "drivers"
  add_foreign_key "trips", "users"
end
