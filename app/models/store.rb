require 'amazon/mws'
require 'RubyOmx'

class Store < ActiveRecord::Base	
	has_many :mws_requests, :dependent => :destroy
	validates_inclusion_of :store_type, :in => %w(MWS), :message => 'Invalid store type'
	validates_uniqueness_of :name, :scope => [:store_type]
	after_initialize :init_mws_connection
	
	US_MKT = "ATVPDKIKX0DER"
	MAX_ORDER_PAGES = 1
	ORDER_RESULTS_PER_PAGE = 1 #1-100
	MAX_FAILURE_COUNT = 2
	ORDER_FAIL_WAIT = 60
	
	@mws_connection = nil
	@cutoff_time = nil

	def fetch_recent_orders 		
		response_id = fetch_orders
		if !response_id.nil?
			response = MwsResponse.find(response_id)	
			return "Error - #{response.error_code}: #{response.error_message}"
		end
		return "OK"
	end

	private
	def init_mws_connection

		#@cutoff_time = self.mws_requests.where(:request_type => "ListOrders").order('updated_at DESC').first.get_last_date
		@cutoff_time = Time.now.yesterday
		
		if self.name=="HDO"
			@mws_connection = Amazon::MWS::Base.new(
				"access_key"=>"AKIAIIPPIV2ZWUHDD5HA",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A3VX72MEBB21JI",
  			"marketplace_id"=>US_MKT
			)
		elsif self.name=="HDO Webstore"
			@mws_connection = Amazon::MWS::Base.new(
				"access_key"=>"AKIAJLQG3YW3XKDQVDIQ",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A3HFI0FEL8PQWZ",
  			"marketplace_id"=>"A1MY0E7E4IHPQT"
			)
		else
			@mws_connection = Amazon::MWS::Base.new(
		  	"access_key"=>"AKIAIUCCPIMBYXZOZMXQ",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A39CG4I2IXB4I2",
  			"marketplace_id"=>US_MKT
  		)
 		end	
	end

	def fetch_orders		
		request = MwsRequest.create!(:request_type => "ListOrders", :store_id => self.id) 
		response = @mws_connection.get_orders_list(      
			:last_updated_after => @cutoff_time.iso8601,
			:results_per_page => ORDER_RESULTS_PER_PAGE,
      :fulfillment_channel => ["MFN"], #TODO include AFN?
			:order_status => ["Unshipped", "PartiallyShipped"], #TODO include shipped?
			:marketplace_id => [US_MKT]
		)
		next_token = request.process_response(@mws_connection,response,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<MAX_ORDER_PAGES do
			response = @mws_connection.get_orders_list_by_next_token(:next_token => next_token)
			n = request.process_response(@mws_connection,response,page_num,ORDER_FAIL_WAIT)
			if n.is_a?(Numeric)
				failure_count += 1
				if failure_count >= MAX_FAILURE_COUNT
					return n
				end
			else
				page_num += 1
				next_token = n
			end
		end
	end
	
end
