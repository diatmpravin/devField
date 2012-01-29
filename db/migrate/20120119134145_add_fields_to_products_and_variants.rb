class AddFieldsToProductsAndVariants < ActiveRecord::Migration
  def change
  	add_column :variants, :sale_price, :float
  	add_column :variants, :msrp, :float
  	add_column :variants, :currency, :string
  	
  	add_column :variants, :leadtime_to_ship, :integer
  	
  	add_column :variants, :asin, :text
  	add_column :sub_variants, :asin, :text
  	add_column :sub_variants, :size_code, :text
  	
  	add_column :products, :product_type, :string, :default => 'Accessory' # amazon clothing-type
  	add_column :products, :variation_theme, :string, :default => 'Color' # amazon clothing-type
  	add_column :products, :department, :string # amazon department, female-adult
  	add_column :products, :file_date, :datetime
  	add_column :products, :amazon_template, :string
  	add_column :products, :keywords, :text
  	add_column :products, :keywords2, :text
  	add_column :products, :keywords3, :text
  	
  	add_index :mws_orders, :purchase_date
  	add_index :states, :raw_state
  	
  end
end
