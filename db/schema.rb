# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_180_527_021_019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'eald_payments', force: :cascade do |t|
    t.integer  'event_id'
    t.string   'stripe_charge_id',                              null: false
    t.integer  'amount_charged_cents',                          null: false
    t.string   'name',                  limit: 255,             null: false
    t.string   'email',                 limit: 255,             null: false
    t.integer  'early_arrival_passes',              default: 0, null: false
    t.integer  'late_departure_passes',             default: 0, null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'event_admins', force: :cascade do |t|
    t.integer  'event_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'event_admins', %w[event_id user_id], name: 'index_event_admins_on_event_id_and_user_id', unique: true,
                                                  using: :btree
  add_index 'event_admins', ['user_id'], name: 'index_event_admins_on_user_id', using: :btree

  create_table 'events', force: :cascade do |t|
    t.string   'name'
    t.datetime 'start_time'
    t.datetime 'end_time'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.decimal  'adult_ticket_price',            precision: 8, scale: 2
    t.decimal  'kid_ticket_price',              precision: 8, scale: 2
    t.decimal  'cabin_price',                   precision: 8, scale: 2
    t.integer  'max_adult_tickets_per_request'
    t.integer  'max_kid_tickets_per_request'
    t.integer  'max_cabins_per_request'
    t.integer  'max_cabin_requests'
    t.string   'photo'
    t.boolean  'tickets_require_approval',                              default: true,  null: false
    t.boolean  'require_mailing_address',                               default: false, null: false
    t.boolean  'allow_financial_assistance',                            default: false, null: false
    t.boolean  'allow_donations',                                       default: false, null: false
    t.datetime 'ticket_sales_start_time'
    t.datetime 'ticket_sales_end_time'
    t.datetime 'ticket_requests_end_time'
    t.decimal  'early_arrival_price',           precision: 8, scale: 2, default: 0.0
    t.decimal  'late_departure_price',          precision: 8, scale: 2, default: 0.0
  end

  create_table 'jobs', force: :cascade do |t|
    t.integer  'event_id',                null: false
    t.string   'name',        limit: 100, null: false
    t.string   'description', limit: 512, null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'payments', force: :cascade do |t|
    t.integer  'ticket_request_id', null: false
    t.string   'stripe_charge_id',  limit: 255
    t.string   'status',            limit: 1, default: 'P', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'explanation'
  end

  create_table 'price_rules', force: :cascade do |t|
    t.string   'type'
    t.integer  'event_id'
    t.decimal  'price', precision: 8, scale: 2
    t.integer  'trigger_value'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'price_rules', ['event_id'], name: 'index_price_rules_on_event_id', using: :btree

  create_table 'shifts', force: :cascade do |t|
    t.integer  'time_slot_id',            null: false
    t.integer  'user_id',                 null: false
    t.string   'name', limit: 70
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'site_admins', force: :cascade do |t|
    t.integer  'user_id', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'ticket_requests', force: :cascade do |t|
    t.integer  'adults',                                                      default: 1,           null: false
    t.integer  'kids',                                                        default: 0,           null: false
    t.integer  'cabins',                                                      default: 0,           null: false
    t.boolean  'needs_assistance',                                            default: false,       null: false
    t.string   'notes',                   limit: 500
    t.string   'status',                  limit: 1, null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'user_id', null: false
    t.decimal  'special_price', precision: 8, scale: 2
    t.integer  'event_id', null: false
    t.decimal  'donation', precision: 8, scale: 2, default: 0.0
    t.string   'role', default: 'volunteer', null: false
    t.string   'role_explanation',        limit: 200
    t.string   'previous_contribution',   limit: 250
    t.string   'address_line1',           limit: 200
    t.string   'address_line2',           limit: 200
    t.string   'city',                    limit: 50
    t.string   'state',                   limit: 50
    t.string   'zip_code',                limit: 32
    t.string   'country_code',            limit: 4
    t.string   'admin_notes',             limit: 512
    t.boolean  'car_camping'
    t.string   'car_camping_explanation', limit: 200
    t.boolean  'agrees_to_terms'
    t.integer  'early_arrival_passes',                                        default: 0,           null: false
    t.integer  'late_departure_passes',                                       default: 0,           null: false
    t.text     'guests'
  end

  create_table 'time_slots', force: :cascade do |t|
    t.integer  'job_id',     null: false
    t.datetime 'start_time', null: false
    t.datetime 'end_time',   null: false
    t.integer  'slots',      null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'users', force: :cascade do |t|
    t.string   'email',                                         null: false
    t.string   'encrypted_password',                            null: false
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer  'sign_in_count', default: 0
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string   'current_sign_in_ip'
    t.string   'last_sign_in_ip'
    t.string   'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string   'unconfirmed_email'
    t.integer  'failed_attempts', default: 0
    t.string   'unlock_token'
    t.datetime 'locked_at'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'name',                   limit: 70, null: false
    t.string   'authentication_token',   limit: 64
  end

  add_index 'users', ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true, using: :btree
  add_index 'users', ['email'], name: 'index_users_on_email', unique: true, using: :btree
  add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true, using: :btree
  add_index 'users', ['unlock_token'], name: 'index_users_on_unlock_token', unique: true, using: :btree
end
