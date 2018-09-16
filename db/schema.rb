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

ActiveRecord::Schema.define(version: 2018_09_16_033921) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "wxpays", force: :cascade do |t|
    t.string "no"
    t.string "source_no"
    t.string "out_transaction_no"
    t.string "status"
    t.string "out_source_status"
    t.string "kind"
    t.string "openid"
    t.string "appid"
    t.decimal "total_fee", precision: 12, scale: 2, default: "0.0"
    t.decimal "refund_amount", precision: 12, scale: 2, default: "0.0"
    t.string "trade_type"
    t.string "code_url"
    t.string "prepay_id"
    t.string "mweb_url"
    t.string "request_params"
    t.string "response_params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["no"], name: "index_wxpays_on_no"
    t.index ["source_no"], name: "index_wxpays_on_source_no"
  end

end
