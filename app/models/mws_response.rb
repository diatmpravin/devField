class MwsResponse < ActiveRecord::Base
	has_many :mws_orders, :dependent => :destroy
	belongs_to :mws_request
end
