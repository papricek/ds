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

ActiveRecord::Schema[8.0].define(version: 2026_03_30_120303) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain"
    t.jsonb "settings", default: {}
    t.string "plan", default: "light", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.string "ean", null: false
    t.string "role", null: false
    t.string "street"
    t.string "city"
    t.string "zip"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_addresses_on_account_id"
    t.index ["ean", "account_id"], name: "index_addresses_on_ean_and_account_id", unique: true
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "group_customers", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "ean", null: false
    t.date "valid_from"
    t.date "valid_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "ean"], name: "index_group_customers_on_group_id_and_ean", unique: true
    t.index ["group_id"], name: "index_group_customers_on_group_id"
  end

  create_table "group_supplier_allocations", force: :cascade do |t|
    t.bigint "group_customer_id", null: false
    t.string "ean", null: false
    t.decimal "allocation_ratio", precision: 5, scale: 4, default: "1.0"
    t.integer "allocation_order", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_customer_id"], name: "index_group_supplier_allocations_on_group_customer_id"
  end

  create_table "groups", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_groups_on_account_id"
  end

  create_table "sharings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "from_address_id", null: false
    t.bigint "to_address_id", null: false
    t.string "from_ean", null: false
    t.string "to_ean", null: false
    t.string "status", default: "active", null: false
    t.decimal "fixed_price", precision: 10, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sharings_on_account_id"
    t.index ["from_address_id"], name: "index_sharings_on_from_address_id"
    t.index ["from_ean", "to_ean", "account_id"], name: "index_sharings_on_from_ean_and_to_ean_and_account_id", unique: true
    t.index ["to_address_id"], name: "index_sharings_on_to_address_id"
  end

  create_table "user_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.integer "kind", null: false
    t.datetime "issued_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_user_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_user_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "password_digest", null: false
    t.string "role", default: "user", null: false
    t.boolean "confirmed", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "accounts"
  add_foreign_key "addresses", "users"
  add_foreign_key "group_customers", "groups"
  add_foreign_key "group_supplier_allocations", "group_customers"
  add_foreign_key "groups", "accounts"
  add_foreign_key "sharings", "accounts"
  add_foreign_key "sharings", "addresses", column: "from_address_id"
  add_foreign_key "sharings", "addresses", column: "to_address_id"
  add_foreign_key "user_tokens", "users"
  add_foreign_key "users", "accounts"
end
