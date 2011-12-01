class OmxRequest < ActiveRecord::Base
	belongs_to :mws_order
	has_many :omx_responses
end
