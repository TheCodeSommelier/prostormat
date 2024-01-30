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

ActiveRecord::Schema[7.1].define(version: 20_240_130_094_250) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'bokees', force: :cascade do |t|
    t.string 'phone_number'
    t.string 'email'
    t.string 'full_name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'orders', force: :cascade do |t|
    t.bigint 'bokee_id', null: false
    t.bigint 'venue_id', null: false
    t.string 'event_type'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'cancelled'
    t.index ['bokee_id'], name: 'index_orders_on_bokee_id'
    t.index ['venue_id'], name: 'index_orders_on_venue_id'
  end

  create_table 'places', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'place_name'
    t.string 'address'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_places_on_user_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'company_name'
    t.string 'phone_number'
    t.string 'company_address'
    t.string 'ico'
    t.string 'dic'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end

  create_table 'venues', force: :cascade do |t|
    t.bigint 'place_id', null: false
    t.integer 'capacity'
    t.text 'description'
    t.string 'venue_name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['place_id'], name: 'index_venues_on_place_id'
  end

  add_foreign_key 'orders', 'bokees'
  add_foreign_key 'orders', 'venues'
  add_foreign_key 'places', 'users'
  add_foreign_key 'venues', 'places'
end
