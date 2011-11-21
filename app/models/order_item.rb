class OrderItem < ActiveRecord::Base
	belongs_to :order
	validates_uniqueness_of :amazon_order_item_id
	validates_presence_of :order_id		
end