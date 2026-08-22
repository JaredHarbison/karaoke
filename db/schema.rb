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

ActiveRecord::Schema[7.2].define(version: 2026_08_21_213000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_host_delegations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "delegated_user_id", null: false
    t.bigint "delegated_by_user_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delegated_by_user_id"], name: "index_event_host_delegations_on_delegated_by_user_id"
    t.index ["delegated_user_id"], name: "index_event_host_delegations_on_delegated_user_id"
    t.index ["event_id", "starts_at", "ends_at"], name: "idx_on_event_id_starts_at_ends_at_e340379ba6"
    t.index ["event_id"], name: "index_event_host_delegations_on_event_id"
  end

  create_table "event_presence_sessions", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "created_by_user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_user_id"], name: "index_event_presence_sessions_on_created_by_user_id"
    t.index ["event_id", "expires_at"], name: "index_event_presence_sessions_on_event_id_and_expires_at"
    t.index ["event_id"], name: "index_event_presence_sessions_on_event_id"
    t.index ["token"], name: "index_event_presence_sessions_on_token", unique: true
  end

  create_table "event_series", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "name", null: false
    t.string "recurrence_rule", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.string "time_zone", default: "UTC", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["venue_id", "active"], name: "index_event_series_on_venue_id_and_active"
    t.index ["venue_id"], name: "index_event_series_on_venue_id"
  end

  create_table "event_setting_changes", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id", null: false
    t.string "setting", null: false
    t.boolean "previous_value", null: false
    t.boolean "new_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "created_at"], name: "index_event_setting_changes_on_event_id_and_created_at"
    t.index ["event_id"], name: "index_event_setting_changes_on_event_id"
    t.index ["user_id"], name: "index_event_setting_changes_on_user_id"
  end

  create_table "event_theme_applications", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "theme_id", null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "theme_id"], name: "index_event_theme_applications_on_event_id_and_theme_id", unique: true
    t.index ["event_id"], name: "index_event_theme_applications_on_event_id"
    t.index ["theme_id"], name: "index_event_theme_applications_on_theme_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.bigint "event_series_id"
    t.string "name", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "fair_queue_enabled", default: true, null: false
    t.boolean "allow_queue_overrun", default: false, null: false
    t.index ["event_series_id", "starts_at"], name: "index_events_on_event_series_id_and_starts_at", unique: true
    t.index ["event_series_id"], name: "index_events_on_event_series_id"
    t.index ["venue_id", "starts_at"], name: "index_events_on_venue_id_and_starts_at"
    t.index ["venue_id"], name: "index_events_on_venue_id"
  end

  create_table "platform_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_platform_memberships_on_user_id"
  end

  create_table "song_queue_overrides", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "song_id", null: false
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.integer "spots_back"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "created_at"], name: "index_song_queue_overrides_on_event_id_and_created_at"
    t.index ["event_id"], name: "index_song_queue_overrides_on_event_id"
    t.index ["song_id"], name: "index_song_queue_overrides_on_song_id"
    t.index ["user_id"], name: "index_song_queue_overrides_on_user_id"
  end

  create_table "songs", force: :cascade do |t|
    t.string "category"
    t.string "performer"
    t.string "url"
    t.boolean "postponed", default: false
    t.boolean "finished", default: false
    t.boolean "skipped", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "venue_id"
    t.bigint "user_id"
    t.string "title"
    t.bigint "event_id"
    t.string "provider", default: "youtube", null: false
    t.string "provider_video_id"
    t.string "metadata_status", default: "legacy", null: false
    t.boolean "explicit_lyrics"
    t.integer "duration_seconds"
    t.integer "effective_duration_seconds"
    t.string "duration_source"
    t.datetime "metadata_checked_at"
    t.string "submission_token"
    t.bigint "theme_application_id"
    t.string "theme_admission_status", default: "not_applicable", null: false
    t.string "theme_admission_reason"
    t.bigint "theme_reviewed_by_id"
    t.datetime "theme_reviewed_at"
    t.index ["event_id", "theme_admission_status"], name: "index_songs_on_event_id_and_theme_admission_status"
    t.index ["event_id"], name: "index_songs_on_event_id"
    t.index ["provider", "provider_video_id"], name: "index_songs_on_provider_and_provider_video_id"
    t.index ["submission_token"], name: "index_songs_on_submission_token", unique: true, where: "(submission_token IS NOT NULL)"
    t.index ["theme_application_id"], name: "index_songs_on_theme_application_id"
    t.index ["theme_reviewed_by_id"], name: "index_songs_on_theme_reviewed_by_id"
    t.index ["user_id", "created_at"], name: "index_songs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_songs_on_user_id"
    t.index ["venue_id", "created_at"], name: "index_songs_on_venue_id_and_created_at"
    t.index ["venue_id"], name: "index_songs_on_venue_id"
  end

  create_table "themes", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "name", null: false
    t.text "description"
    t.jsonb "rules", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["venue_id", "name"], name: "index_themes_on_venue_id_and_name", unique: true
    t.index ["venue_id"], name: "index_themes_on_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.bigint "venue_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["venue_id"], name: "index_users_on_venue_id"
  end

  create_table "venue_invitations", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.bigint "invited_by_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "accepted_at"
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invited_by_id"], name: "index_venue_invitations_on_invited_by_id"
    t.index ["token"], name: "index_venue_invitations_on_token", unique: true
    t.index ["venue_id", "email"], name: "index_venue_invitations_on_venue_id_and_email"
    t.index ["venue_id"], name: "index_venue_invitations_on_venue_id"
  end

  create_table "venue_memberships", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_venue_memberships_on_user_id"
    t.index ["venue_id", "role"], name: "index_venue_memberships_on_venue_id_and_role"
    t.index ["venue_id", "user_id"], name: "index_venue_memberships_on_venue_id_and_user_id", unique: true
    t.index ["venue_id"], name: "index_venue_memberships_on_venue_id"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "location"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "owner_id"
    t.boolean "public", default: true
    t.string "presence_token"
    t.boolean "explicit_lyrics_allowed", default: false, null: false
    t.index ["owner_id"], name: "index_venues_on_owner_id"
    t.index ["presence_token"], name: "index_venues_on_presence_token", unique: true
    t.index ["public"], name: "index_venues_on_public"
    t.index ["slug"], name: "index_venues_on_slug", unique: true
  end

  add_foreign_key "event_host_delegations", "events"
  add_foreign_key "event_host_delegations", "users", column: "delegated_by_user_id"
  add_foreign_key "event_host_delegations", "users", column: "delegated_user_id"
  add_foreign_key "event_presence_sessions", "events"
  add_foreign_key "event_presence_sessions", "users", column: "created_by_user_id"
  add_foreign_key "event_series", "venues"
  add_foreign_key "event_setting_changes", "events"
  add_foreign_key "event_setting_changes", "users"
  add_foreign_key "event_theme_applications", "events"
  add_foreign_key "event_theme_applications", "themes"
  add_foreign_key "events", "event_series"
  add_foreign_key "events", "venues"
  add_foreign_key "platform_memberships", "users"
  add_foreign_key "song_queue_overrides", "events"
  add_foreign_key "song_queue_overrides", "songs"
  add_foreign_key "song_queue_overrides", "users"
  add_foreign_key "songs", "event_theme_applications", column: "theme_application_id"
  add_foreign_key "songs", "events"
  add_foreign_key "songs", "users"
  add_foreign_key "songs", "users", column: "theme_reviewed_by_id"
  add_foreign_key "songs", "venues"
  add_foreign_key "themes", "venues"
  add_foreign_key "users", "venues"
  add_foreign_key "venue_invitations", "users", column: "invited_by_id"
  add_foreign_key "venue_invitations", "venues"
  add_foreign_key "venue_memberships", "users"
  add_foreign_key "venue_memberships", "venues"
  add_foreign_key "venues", "users", column: "owner_id"
end
