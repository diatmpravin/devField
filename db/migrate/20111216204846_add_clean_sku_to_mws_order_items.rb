class AddCleanSkuToMwsOrderItems < ActiveRecord::Migration
  def change
    add_column :mws_order_items, :clean_sku, :string
  end
end
