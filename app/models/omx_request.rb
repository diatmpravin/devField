class OmxRequest < ActiveRecord::Base
	belongs_to :mws_order
	has_one :omx_response, :dependent => :destroy
end
