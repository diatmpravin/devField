class AddSkuIndexes < ActiveRecord::Migration
  def change
  	add_column :products, :base_sku, :string
  	add_index :products, :base_sku
  	add_index :variants, :sku
  	add_index :variants, :amazon_product_id
  end
end
