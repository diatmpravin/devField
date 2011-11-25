class MwsOrderItem < ActiveRecord::Base
	belongs_to :mws_order
	validates_uniqueness_of :amazon_order_item_id
	validates_presence_of :mws_order_id		
end