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

ActiveRecord::Schema[7.2].define(version: 2026_08_21_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "platform_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_platform_memberships_on_user_id"
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
    t.index ["user_id", "created_at"], name: "index_songs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_songs_on_user_id"
    t.index ["venue_id", "created_at"], name: "index_songs_on_venue_id_and_created_at"
    t.index ["venue_id"], name: "index_songs_on_venue_id"
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
    t.index ["owner_id"], name: "index_venues_on_owner_id"
    t.index ["public"], name: "index_venues_on_public"
    t.index ["slug"], name: "index_venues_on_slug", unique: true
  end

  add_foreign_key "platform_memberships", "users"
  add_foreign_key "songs", "users"
  add_foreign_key "songs", "venues"
  add_foreign_key "users", "venues"
  add_foreign_key "venue_invitations", "users", column: "invited_by_id"
  add_foreign_key "venue_invitations", "venues"
  add_foreign_key "venue_memberships", "users"
  add_foreign_key "venue_memberships", "venues"
  add_foreign_key "venues", "users", column: "owner_id"
end
