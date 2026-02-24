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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_155250) do
  create_table "contributions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "contribution_date", null: false
    t.datetime "created_at", null: false
    t.integer "policy_id", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id", "contribution_date"], name: "index_contributions_on_policy_id_and_contribution_date"
    t.index ["policy_id"], name: "index_contributions_on_policy_id"
  end

  create_table "fund_nav_prices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "fund_id", null: false
    t.decimal "nav", precision: 12, scale: 4, null: false
    t.decimal "previous_close", precision: 12, scale: 4
    t.date "price_date", null: false
    t.datetime "updated_at", null: false
    t.index ["fund_id", "price_date"], name: "index_fund_nav_prices_on_fund_id_and_price_date", unique: true
    t.index ["fund_id"], name: "index_fund_nav_prices_on_fund_id"
    t.index ["price_date"], name: "index_fund_nav_prices_on_price_date"
  end

  create_table "funds", force: :cascade do |t|
    t.decimal "allocation_pct", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.string "isin", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.string "yahoo_ticker"
    t.index ["isin"], name: "index_funds_on_isin", unique: true
  end

  create_table "holdings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "fund_id", null: false
    t.integer "policy_id", null: false
    t.decimal "units", precision: 15, scale: 6, default: "0.0", null: false
    t.date "units_as_of_date"
    t.datetime "updated_at", null: false
    t.index ["fund_id", "policy_id"], name: "index_holdings_on_fund_id_and_policy_id", unique: true
    t.index ["fund_id"], name: "index_holdings_on_fund_id"
    t.index ["policy_id"], name: "index_holdings_on_policy_id"
  end

  create_table "policies", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.date "inception_date", null: false
    t.string "name", null: false
    t.integer "policy_type", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_policies_on_slug", unique: true
  end

  create_table "policy_snapshots", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "monthly_change", precision: 12, scale: 2
    t.integer "policy_id", null: false
    t.date "snapshot_date", null: false
    t.decimal "total_contributed", precision: 12, scale: 2
    t.decimal "total_delta", precision: 12, scale: 2
    t.decimal "total_value", precision: 12, scale: 2
    t.datetime "updated_at", null: false
    t.index ["policy_id", "snapshot_date"], name: "index_policy_snapshots_on_policy_id_and_snapshot_date", unique: true
    t.index ["policy_id"], name: "index_policy_snapshots_on_policy_id"
    t.index ["snapshot_date"], name: "index_policy_snapshots_on_snapshot_date"
  end

  add_foreign_key "contributions", "policies"
  add_foreign_key "fund_nav_prices", "funds"
  add_foreign_key "holdings", "funds"
  add_foreign_key "holdings", "policies"
  add_foreign_key "policy_snapshots", "policies"
end
