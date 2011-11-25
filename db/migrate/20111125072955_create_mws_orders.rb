class CreateMwsOrders < ActiveRecord::Migration
  def change
    create_table :mws_orders do |t|
      t.string :amazon_order_id
      t.string :seller_order_id
      t.datetime :purchase_date
      t.datetime :last_update_date
      t.string :order_status
      t.string :fulfillment_channel
      t.string :sales_channel
      t.string :order_channel
      t.string :ship_service_level
      t.float :amount
      t.string :currency_code
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_line_3
      t.string :city
      t.string :county
      t.string :district
      t.string :state_or_region
      t.string :postal_code
      t.string :country_code
      t.string :phone
      t.integer :number_of_items_shipped
      t.integer :number_of_items_unshipped
      t.string :marketplace_id
      t.string :buyer_name
      t.string :buyer_email
      t.string :ship_service_level_category
      t.integer :mws_response_id

      t.timestamps
    end
  end
end
