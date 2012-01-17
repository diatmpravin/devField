class SubVariant < ActiveRecord::Base
	belongs_to :variant
	validates_uniqueness_of :sku
	validates_uniqueness_of :upc, :allow_nil => true
	
	
end
