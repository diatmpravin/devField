class RenameOrderItemFieldsAndAddSourceToSkuMapping < ActiveRecord::Migration
  def change
  	add_column :sku_mappings, :source, :string, :default=>'manual'
  	
  	rename_column :mws_order_items, :parent_product_id, :product_id
  	rename_column :mws_order_items, :parent_variant_id, :variant_id
  	rename_column :mws_order_items, :parent_sub_variant_id, :sub_variant_id
  end
end
