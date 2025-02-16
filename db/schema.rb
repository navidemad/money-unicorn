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

ActiveRecord::Schema[8.1].define(version: 2025_02_15_205821) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "youtube_channels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "language"
    t.string "niche"
    t.string "nickname"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_youtube_channels_on_user_id"
  end

  create_table "youtube_shorts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aspect_ratio"
    t.string "concatenation_mode"
    t.datetime "created_at", null: false
    t.boolean "enable_subtitles"
    t.text "keywords"
    t.string "language"
    t.integer "max_duration"
    t.text "script"
    t.integer "simultaneous_videos"
    t.string "source"
    t.string "subject"
    t.string "subtitle_color"
    t.string "subtitle_font"
    t.string "subtitle_outline_color"
    t.decimal "subtitle_outline_width"
    t.string "subtitle_position"
    t.integer "subtitle_size"
    t.datetime "updated_at", null: false
    t.uuid "youtube_channel_id", null: false
    t.index ["youtube_channel_id"], name: "index_youtube_shorts_on_youtube_channel_id"
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "youtube_channels", "users"
  add_foreign_key "youtube_shorts", "youtube_channels"
end
