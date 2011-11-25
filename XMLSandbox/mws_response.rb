class MwsResponse < ActiveRecord::Base
	has_many :mws_orders
	belongs_to :mws_request
end
