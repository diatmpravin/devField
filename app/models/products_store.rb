class ProductsStore < ActiveRecord::Base
	belongs_to :store
	belongs_to :product
	validates_uniqueness_of :product_id, :handle, :foreign_id, :scope => [:store_id]
end
