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

ActiveRecord::Schema.define(version: 2020_08_24_155629) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "bonus_trips", force: :cascade do |t|
    t.integer "status", default: 0
    t.bigint "user_id"
    t.bigint "friend_id"
    t.bigint "trip_id"
    t.string "code"
    t.string "type"
    t.index ["friend_id"], name: "index_bonus_trips_on_friend_id"
    t.index ["trip_id"], name: "index_bonus_trips_on_trip_id"
    t.index ["user_id"], name: "index_bonus_trips_on_user_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "card_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_businesses_on_card_id"
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "businesses_users", id: false, force: :cascade do |t|
    t.integer "business_id"
    t.integer "user_id"
    t.index ["business_id", "user_id"], name: "index_businesses_users_on_business_id_and_user_id", unique: true
  end

  create_table "cards", force: :cascade do |t|
    t.string "token"
    t.string "pan"
    t.string "type"
    t.string "currency"
    t.bigint "user_id"
    t.boolean "default", default: false
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "cars", force: :cascade do |t|
    t.string "number"
    t.integer "status", default: 0
    t.string "color"
    t.string "phone_number"
  end

  create_table "devices", force: :cascade do |t|
    t.string "token"
    t.string "platform"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.string "username"
    t.string "encrypted_password"
    t.string "auth_token"
    t.bigint "car_id"
    t.string "address"
    t.decimal "address_location", default: [], array: true
    t.index ["car_id"], name: "index_drivers_on_car_id"
  end

  create_table "favorite_addresses", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.index ["user_id"], name: "index_favorite_addresses_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer "rate", default: 0
    t.text "description"
    t.bigint "trip_id"
    t.bigint "user_id"
    t.index ["trip_id"], name: "index_feedbacks_on_trip_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "vendor_id"
    t.bigint "trip_id"
    t.hstore "items"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trip_id"], name: "index_orders_on_trip_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
    t.index ["vendor_id"], name: "index_orders_on_vendor_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount"
    t.integer "status", default: 0
    t.bigint "card_id"
    t.bigint "trip_id"
    t.string "order_reference"
    t.bigint "user_id"
    t.jsonb "response"
    t.string "type", default: "Payments::Trip"
    t.bigint "order_id"
    t.index ["card_id"], name: "index_payments_on_card_id"
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["trip_id"], name: "index_payments_on_trip_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "prices", force: :cascade do |t|
    t.integer "cents_per_km", default: 600
    t.integer "outside_cents_per_km", default: 900
    t.integer "landing", default: 2000
    t.integer "idle_price", default: 1
    t.integer "min_price", default: 4000
    t.float "coefficient", default: 1.0
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
    t.datetime "created_at", default: -> { "now()" }
    t.integer "distance"
    t.integer "duration"
    t.datetime "start_at"
    t.datetime "finish_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "arrived_at"
    t.string "comment"
    t.text "waypoints", default: [], array: true
    t.text "stops", default: [], array: true
    t.integer "idle", default: 0
    t.integer "total", default: 0
    t.boolean "no_call", default: false
    t.datetime "preorder_time"
    t.datetime "accepted_at"
    t.index ["car_id"], name: "index_trips_on_car_id"
    t.index ["driver_id"], name: "index_trips_on_driver_id"
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "user_telegrams", force: :cascade do |t|
    t.bigint "user_id"
    t.string "username"
    t.string "chat_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_telegrams_on_user_id"
    t.index ["username"], name: "index_user_telegrams_on_username"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "auth_token"
    t.string "referral_code"
    t.datetime "created_at", default: -> { "now()" }
    t.integer "trips_count", default: 0
    t.boolean "vip", default: false
    t.string "notification_settings", default: [], array: true
    t.string "locale", default: "uk"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "location"
    t.string "address"
    t.string "url"
    t.string "api_url"
    t.string "logo_url"
    t.time "open_at"
    t.time "close_at"
    t.string "telegram_account"
    t.string "phone_number"
    t.boolean "active", default: true
    t.integer "orders_count", default: 0
    t.boolean "need_approve", default: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.string "whodunnit_type"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "bonus_trips", "trips"
  add_foreign_key "bonus_trips", "users"
  add_foreign_key "bonus_trips", "users", column: "friend_id"
  add_foreign_key "businesses", "users"
  add_foreign_key "cards", "users"
  add_foreign_key "devices", "users"
  add_foreign_key "drivers", "cars"
  add_foreign_key "favorite_addresses", "users"
  add_foreign_key "feedbacks", "trips"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "orders", "trips"
  add_foreign_key "orders", "users"
  add_foreign_key "orders", "vendors"
  add_foreign_key "payments", "cards"
  add_foreign_key "payments", "orders"
  add_foreign_key "payments", "trips"
  add_foreign_key "trips", "cars"
  add_foreign_key "trips", "drivers"
  add_foreign_key "trips", "users"
  add_foreign_key "user_telegrams", "users"
end
