class AddAmazonOrderIdToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :amazon_order_id, :string
  end
end
