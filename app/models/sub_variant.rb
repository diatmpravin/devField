class SubVariant < ActiveRecord::Base
	belongs_to :variant
	has_many :mws_order_items, :class_name => 'MwsOrderItem', :foreign_key => 'clean_sku', :primary_key => 'sku'
	validates_uniqueness_of :sku
	validates_uniqueness_of :upc, :allow_nil => true
	
	
	
end
