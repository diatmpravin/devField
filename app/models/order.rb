class Order < ActiveRecord::Base
	belongs_to :response
	has_many :order_items
	validates_uniqueness_of :amazon_order_id
	validates_presence_of :response_id
end