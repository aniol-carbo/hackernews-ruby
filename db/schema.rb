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

ActiveRecord::Schema.define(version: 2021_04_30_063456) do

  create_table "comments", force: :cascade do |t|
    t.string "text"
    t.boolean "escomment"
    t.integer "points", default: 1
    t.integer "user", null: false
    t.integer "contribution", null: false
    t.integer "comment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "author"
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.string "url"
    t.string "title"
    t.datetime "updated_at"
    t.integer "points", default: 0
    t.integer "user_id"
    t.boolean "ask", default: false
    t.string "shorturl"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.string "google_token"
    t.string "google_refresh_token"
    t.string "provider", limit: 50, default: "", null: false
    t.string "uid", limit: 500, default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "locked_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "karma", default: 0
    t.text "about"
    t.string "api_key"
  end

  create_table "votes", force: :cascade do |t|
    t.string "tipus", null: false
    t.integer "idType", null: false
    t.integer "idUser", null: false
    t.datetime "created_at"
    t.index ["tipus", "idType", "idUser"], name: "index_vote_on_type_idType_idUser", unique: true
  end

end
