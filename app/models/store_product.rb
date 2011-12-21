class StoreProduct < ActiveRecord::Base
	belongs_to :store
	belongs_to :product
	validates_presence_of :store_id
	validates_presence_of :product_id
end
