class AddParentProductIdToMwsOrderItems < ActiveRecord::Migration
  def change
    add_column :mws_order_items, :parent_product_id, :integer
    add_column :mws_order_items, :parent_variant_id, :integer
    add_column :mws_order_items, :parent_sub_variant_id, :integer
  end
end
