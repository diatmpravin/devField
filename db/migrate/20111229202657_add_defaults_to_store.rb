class AddDefaultsToStore < ActiveRecord::Migration
  def change
  	change_column_default(:stores, :queue_flag, 'False')
  	change_column_default(:stores, :verify_flag, 'True')
  	change_column_default(:stores, :order_results_per_page, 100)
  	change_column_default(:stores, :max_order_pages, 10)
  	change_column_default(:stores, :store_type, 'MWS')
  	change_column_default(:brands, :default_markup, 1.00)
  end
end
