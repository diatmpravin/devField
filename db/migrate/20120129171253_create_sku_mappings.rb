class CreateSkuMappings < ActiveRecord::Migration
  def change
    create_table :sku_mappings do |t|
      t.string :sku
      t.string :granularity
      t.integer :foreign_id
      		
      t.timestamps
    end
    add_index :sku_mappings, :sku, :unique => true
  end
end
