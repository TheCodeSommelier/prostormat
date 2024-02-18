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

ActiveRecord::Schema[7.1].define(version: 2024_02_18_100729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bokees", force: :cascade do |t|
    t.string "phone_number"
    t.string "email"
    t.string "full_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "filters", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "bokee_id", null: false
    t.bigint "venue_id", null: false
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cancelled"
    t.date "date"
    t.time "time"
    t.index ["bokee_id"], name: "index_orders_on_bokee_id"
    t.index ["venue_id"], name: "index_orders_on_venue_id"
  end

  create_table "place_filters", force: :cascade do |t|
    t.bigint "place_id", null: false
    t.bigint "filter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filter_id"], name: "index_place_filters_on_filter_id"
    t.index ["place_id"], name: "index_place_filters_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "place_name"
    t.string "street"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city"
    t.integer "max_capacity"
    t.text "place_description"
    t.string "house_number"
    t.string "postal_code"
    t.index ["user_id"], name: "index_places_on_user_id"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.string "plan_type"
    t.integer "yearly_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_plan_id", null: false
    t.string "stripe_subscription_id"
    t.string "payment_interval"
    t.date "start_date"
    t.date "end_date"
    t.boolean "active"
    t.boolean "cancel_at_current_period_end"
    t.string "stripe_sub_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscription_plan_id"], name: "index_subscriptions_on_subscription_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "company_name"
    t.string "phone_number"
    t.string "company_address"
    t.string "ico"
    t.string "dic"
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.bigint "place_id", null: false
    t.integer "capacity"
    t.text "description"
    t.string "venue_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_venues_on_place_id"
  end

  add_foreign_key "orders", "bokees"
  add_foreign_key "orders", "venues"
  add_foreign_key "place_filters", "filters"
  add_foreign_key "place_filters", "places"
  add_foreign_key "places", "users"
  add_foreign_key "subscriptions", "subscription_plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "venues", "places"
end
