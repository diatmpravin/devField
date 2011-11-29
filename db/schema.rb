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

ActiveRecord::Schema.define(:version => 20111127170109) do

  create_table "imports", :force => true do |t|
    t.string   "datatype"
    t.integer  "processed"
    t.string   "csv_file_name"
    t.string   "csv_content_type"
    t.integer  "csv_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mws_order_items", :force => true do |t|
    t.string   "asin"
    t.string   "amazon_order_item_id"
    t.string   "seller_sku"
    t.string   "title"
    t.integer  "quantity_ordered"
    t.integer  "quantity_shipped"
    t.float    "item_price"
    t.string   "item_price_currency"
    t.float    "shipping_price"
    t.string   "shipping_price_currency"
    t.float    "gift_price"
    t.string   "gift_price_currency"
    t.float    "item_tax"
    t.string   "item_tax_currency"
    t.float    "shipping_tax"
    t.string   "shipping_tax_currency"
    t.float    "gift_tax"
    t.string   "gift_tax_currency"
    t.float    "shipping_discount"
    t.string   "shipping_discount_currency"
    t.float    "promotion_discount"
    t.string   "promotion_discount_currency"
    t.string   "gift_wrap_level"
    t.string   "gift_message_text"
    t.integer  "mws_order_id"
    t.string   "amazon_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mws_orders", :force => true do |t|
    t.string   "amazon_order_id"
    t.string   "seller_order_id"
    t.datetime "purchase_date"
    t.datetime "last_update_date"
    t.string   "order_status"
    t.string   "fulfillment_channel"
    t.string   "sales_channel"
    t.string   "order_channel"
    t.string   "ship_service_level"
    t.float    "amount"
    t.string   "currency_code"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "address_line_3"
    t.string   "city"
    t.string   "county"
    t.string   "district"
    t.string   "state_or_region"
    t.string   "postal_code"
    t.string   "country_code"
    t.string   "phone"
    t.integer  "number_of_items_shipped"
    t.integer  "number_of_items_unshipped"
    t.string   "marketplace_id"
    t.string   "buyer_name"
    t.string   "buyer_email"
    t.string   "ship_service_level_category"
    t.integer  "mws_response_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mws_requests", :force => true do |t|
    t.string   "amazon_request_id"
    t.string   "request_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mws_responses", :force => true do |t|
    t.integer  "mws_request_id"
    t.string   "amazon_request_id"
    t.text     "next_token"
    t.datetime "last_updated_before"
    t.datetime "created_before"
    t.string   "request_type"
    t.integer  "page_num"
    t.string   "error_code"
    t.text     "error_message"
    t.string   "amazon_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
