class MwsResponse < ActiveRecord::Base
	has_many :mws_orders, :dependent => :destroy
	has_many :mws_order_items, :dependent => :destroy
	belongs_to :mws_request
end
