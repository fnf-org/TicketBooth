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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130616002401) do

  create_table "event_admins", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "event_admins", ["event_id", "user_id"], :name => "index_event_admins_on_event_id_and_user_id", :unique => true
  add_index "event_admins", ["user_id"], :name => "index_event_admins_on_user_id"

  create_table "events", :force => true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.decimal  "adult_ticket_price",            :precision => 8, :scale => 2
    t.decimal  "kid_ticket_price",              :precision => 8, :scale => 2
    t.decimal  "cabin_price",                   :precision => 8, :scale => 2
    t.integer  "max_adult_tickets_per_request"
    t.integer  "max_kid_tickets_per_request"
    t.integer  "max_cabins_per_request"
    t.integer  "max_cabin_requests"
    t.string   "photo"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "event_id",                   :null => false
    t.string   "name",        :limit => 100, :null => false
    t.string   "description", :limit => 512, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer  "ticket_request_id",                               :null => false
    t.string   "stripe_charge_id"
    t.string   "status",            :limit => 1, :default => "P", :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  create_table "price_rules", :force => true do |t|
    t.string   "type"
    t.integer  "event_id"
    t.decimal  "price",         :precision => 8, :scale => 2
    t.integer  "trigger_value"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "price_rules", ["event_id"], :name => "index_price_rules_on_event_id"

  create_table "shifts", :force => true do |t|
    t.integer  "time_slot_id",               :null => false
    t.integer  "user_id",                    :null => false
    t.string   "name",         :limit => 70
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "site_admins", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ticket_requests", :force => true do |t|
    t.string   "address",          :limit => 150,                                                  :null => false
    t.integer  "adults",                                                        :default => 1,     :null => false
    t.integer  "kids",                                                          :default => 0,     :null => false
    t.integer  "cabins",                                                        :default => 0,     :null => false
    t.boolean  "needs_assistance",                                              :default => false, :null => false
    t.string   "notes",            :limit => 500
    t.string   "status",           :limit => 1,                                 :default => "P",   :null => false
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
    t.integer  "user_id",                                                                          :null => false
    t.decimal  "special_price",                   :precision => 8, :scale => 2
    t.integer  "event_id",                                                                         :null => false
    t.integer  "volunteer_shifts"
    t.boolean  "performer",                                                     :default => false, :null => false
  end

  create_table "time_slots", :force => true do |t|
    t.integer  "job_id",     :null => false
    t.datetime "start_time", :null => false
    t.datetime "end_time",   :null => false
    t.integer  "slots",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                               :null => false
    t.string   "encrypted_password",                                  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                      :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "name",                   :limit => 70,                :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
