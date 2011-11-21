class RenameOrderItemIdToAmazonOrderItemIdInOrderItems < ActiveRecord::Migration
  def change
    rename_column :order_items, :order_item_id, :amazon_order_item_id 
  end
end
