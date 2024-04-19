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

ActiveRecord::Schema[7.1].define(version: 2024_03_11_182346) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "eald_payments", force: :cascade do |t|
    t.bigint "event_id"
    t.string "stripe_charge_id", null: false
    t.integer "amount_charged_cents", null: false
    t.string "name", limit: 255, null: false
    t.string "email", limit: 255, null: false
    t.integer "early_arrival_passes", default: 0, null: false
    t.integer "late_departure_passes", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_eald_payments_on_event_id"
  end

  create_table "event_admins", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "user_id"], name: "index_event_admins_on_event_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_event_admins_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "adult_ticket_price", precision: 8, scale: 2
    t.decimal "kid_ticket_price", precision: 8, scale: 2
    t.decimal "cabin_price", precision: 8, scale: 2
    t.integer "max_adult_tickets_per_request"
    t.integer "max_kid_tickets_per_request"
    t.integer "max_cabins_per_request"
    t.integer "max_cabin_requests"
    t.string "photo"
    t.boolean "tickets_require_approval", default: true, null: false
    t.boolean "require_mailing_address", default: false, null: false
    t.boolean "allow_financial_assistance", default: false, null: false
    t.boolean "allow_donations", default: false, null: false
    t.datetime "ticket_sales_start_time", precision: nil
    t.datetime "ticket_sales_end_time", precision: nil
    t.datetime "ticket_requests_end_time", precision: nil
    t.decimal "early_arrival_price", precision: 8, scale: 2, default: "0.0"
    t.decimal "late_departure_price", precision: 8, scale: 2, default: "0.0"
  end

  create_table "jobs", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "name", limit: 100, null: false
    t.string "description", limit: 512, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_jobs_on_event_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "ticket_request_id", null: false
    t.string "stripe_charge_id", limit: 255
    t.string "status", limit: 1, default: "P", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "explanation"
  end

  create_table "price_rules", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id"
    t.decimal "price", precision: 8, scale: 2
    t.integer "trigger_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_price_rules_on_event_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.bigint "time_slot_id", null: false
    t.bigint "user_id", null: false
    t.string "name", limit: 70
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id"], name: "index_shifts_on_time_slot_id"
    t.index ["user_id"], name: "index_shifts_on_user_id"
  end

  create_table "site_admins", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ticket_requests", force: :cascade do |t|
    t.integer "adults", default: 1, null: false
    t.integer "kids", default: 0, null: false
    t.integer "cabins", default: 0, null: false
    t.boolean "needs_assistance", default: false, null: false
    t.string "notes", limit: 500
    t.string "status", limit: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "special_price", precision: 8, scale: 2
    t.integer "event_id", null: false
    t.decimal "donation", precision: 8, scale: 2, default: "0.0"
    t.string "role", default: "volunteer", null: false
    t.string "role_explanation", limit: 200
    t.string "previous_contribution", limit: 250
    t.string "address_line1", limit: 200
    t.string "address_line2", limit: 200
    t.string "city", limit: 50
    t.string "state", limit: 50
    t.string "zip_code", limit: 32
    t.string "country_code", limit: 4
    t.string "admin_notes", limit: 512
    t.boolean "car_camping"
    t.string "car_camping_explanation", limit: 200
    t.boolean "agrees_to_terms"
    t.integer "early_arrival_passes", default: 0, null: false
    t.integer "late_departure_passes", default: 0, null: false
    t.text "guests"
  end

  create_table "time_slots", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.datetime "start_time", precision: nil, null: false
    t.datetime "end_time", precision: nil, null: false
    t.integer "slots", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_time_slots_on_job_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", limit: 70, null: false
    t.string "authentication_token", limit: 64
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
