class AddDefaultMarkupToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :default_markup, :float, :default => 1
    add_column :products, :category, :string, :default => 'Sunglasses'
    add_index :products, :category
  end
end
