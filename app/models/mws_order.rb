require 'amazon/mws'

class MwsOrder < ActiveRecord::Base
	belongs_to :mws_response
	has_many :mws_order_items
	validates_uniqueness_of :amazon_order_id
	validates_presence_of :mws_response_id
	
	US_MKT = "ATVPDKIKX0DER" 

	def self.fetch_recent_orders(which)
		
		mws_connection = nil
		cutoff_time = nil
		
		if which=="hdo"
			mws_connection = Amazon::MWS::Base.new(
				"access_key"=>"AKIAIIPPIV2ZWUHDD5HA",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A3VX72MEBB21JI",
  			"marketplace_id"=>US_MKT
			)
			cutoff_time = Time.current().yesterday
		elsif which=="hdo_webstore"
			mws_connection = Amazon::MWS::Base.new(
				"access_key"=>"AKIAJLQG3YW3XKDQVDIQ",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A3HFI0FEL8PQWZ",
  			"marketplace_id"=>"A1MY0E7E4IHPQT"
			)
			cutoff_time = Time.current().yesterday			
		else
			mws_connection = Amazon::MWS::Base.new(
		  	"access_key"=>"AKIAIUCCPIMBYXZOZMXQ",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A39CG4I2IXB4I2",
  			"marketplace_id"=>US_MKT
  		)		 
 			cutoff_time = Time.current().yesterday
 		end
 		
		response_id = MwsOrder.fetch_orders(mws_connection,cutoff_time)
		if !response_id.nil?
			response = MwsResponse.find(response_id)	
			return "Error - #{response.error_code}: #{response.error_message}"
		end
		return "OK"
	end

	def self.fetch_orders(mws_connection,date_since)
		max_pages = 1
		max_failure_count = 2

		request = MwsRequest.create!(:request_type => "ListOrders") 
		response = mws_connection.get_orders_list(      
			:last_updated_after => date_since.iso8601,
			:results_per_page => 3,
      :fulfillment_channel => ["MFN"],
			:order_status => ["Unshipped", "PartiallyShipped", "Shipped"],
			:marketplace_id => [US_MKT]
		)
		next_token = request.process_response(mws_connection,response,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<max_pages do
			response = mws_connection.get_orders_list_by_next_token(:next_token => next_token)
			n = request.process_response(mws_connection,response,page_num,60)
			if n.is_a?(Numeric)
				failure_count += 1
				if failure_count >= max_failure_count
					return n
				end
			else
				page_num += 1
				next_token = n
			end
		end
	end

	# Process XML order into ActiveRecord, and process items on order
	def self.process_order(mws_connection, order, response_id)
		h = MwsHelper.instance_vars_to_hash(order)
		h['mws_response_id'] = response_id
		amz_order = MwsOrder.find_or_create_by_amazon_order_id(order.amazon_order_id)
		amz_order.update_attributes(h)
		return MwsOrder.fetch_order_items(mws_connection, amz_order.amazon_order_id)
	end
	
	def self.fetch_order_items(mws_connection, amazon_order_id)
		max_pages = 5
		max_failure_count = 2
		
		request = MwsRequest.create!(:request_type => "ListOrderItems")
		response = mws_connection.get_list_order_items(:amazon_order_id => amazon_order_id)
		next_token = request.process_response(mws_connection, response,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<max_pages do
			response = mws_connection.get_list_order_items_by_next_token(:next_token => next_token)
			n = request.process_response(mws_connection,response,page_num,15)
			if n.is_a?(Numeric)
				failure_count += 1
				if failure_count >= max_failure_count
					return n
				end
			else
				page_num += 1 # don't want to increment page if there is an error
				next_token = n
			end
		end		
	end

	def self.process_order_item(item, amazon_order_id)
		h = MwsHelper.instance_vars_to_hash(item)
		h['amazon_order_id'] = amazon_order_id
		amz_item = MwsOrderItem.find_or_create_by_amazon_order_item_id_and_mws_order_id(item.amazon_order_item_id,MwsOrder.find_by_amazon_order_id(amazon_order_id).id)		
		amz_item.update_attributes(h)
	end
	
end