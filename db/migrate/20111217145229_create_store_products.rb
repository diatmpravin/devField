class CreateStoreProducts < ActiveRecord::Migration
  def change
    create_table :store_products do |t|
      t.integer :store_id
      t.integer :product_id
      t.string :foreign_id
      t.string :handle
			
      t.timestamps
    end
    add_index :store_products, :product_id
    add_column :stores, :authenticated_url, :string
  end
end
