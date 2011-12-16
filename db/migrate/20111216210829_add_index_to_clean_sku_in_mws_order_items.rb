class AddIndexToCleanSkuInMwsOrderItems < ActiveRecord::Migration
  def change
  	add_index :mws_order_items, :clean_sku
  end
end
