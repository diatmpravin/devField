class AddIndexesToMwsRequests < ActiveRecord::Migration
  def change
  	add_index :mws_order_items, :mws_order_id
  	add_index :mws_order_items, :mws_response_id
  	add_index :mws_order_items, :amazon_order_id
  	add_index :mws_orders, :amazon_order_id
  	add_index :mws_orders, :store_id
  	add_index :mws_orders, :mws_response_id
  	add_index :mws_requests, :mws_request_id
  	add_index :mws_responses, :mws_request_id
  	add_index :mws_responses, :amazon_order_id
  	add_index :omx_requests, :mws_order_id
  	add_index :omx_responses, :omx_request_id
  	add_index :brands, :vendor_id
  	add_index :products, :brand_id
  	add_index :variants, :product_id
  	add_index :variant_images, :variant_id
  end
end
