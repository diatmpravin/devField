require 'amazon/mws'
require 'RubyOmx'

class MwsOrder < ActiveRecord::Base
	belongs_to :mws_response
	has_many :mws_order_items
	has_many :omx_requests
	validates_uniqueness_of :amazon_order_id
	validates_presence_of :mws_response_id
	
	US_MKT = "ATVPDKIKX0DER"
	MAX_ORDER PAGES = 5
	ORDER_RESULTS_PER_PAGE = 100 #1-100
	MAX_ORDER_ITEM_PAGES = 5
	MAX_FAILURE_COUNT = 2
	ORDER_FAIL_WAIT = 60
	ORDER_ITEM_FAIL_WAIT = 15

	def self.get_last_request_date(store)
		return MwsRequest.where(:store => store, :request_type => "ListOrders").order('updated_at DESC').first.get_last_date
	end

	def self.fetch_recent_orders(store)
		
		mws_connection = nil
		#cutoff_time = MwsOrder::get_last_request_date(store)
		cutoff_time = Time.now.yesterday
		
		if store=="HDO"
			mws_connection = Amazon::MWS::Base.new(
				"access_key"=>"AKIAIIPPIV2ZWUHDD5HA",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A3VX72MEBB21JI",
  			"marketplace_id"=>US_MKT
			)
		elsif store=="HDO Webstore"
			mws_connection = Amazon::MWS::Base.new(
				"access_key"=>"AKIAJLQG3YW3XKDQVDIQ",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A3HFI0FEL8PQWZ",
  			"marketplace_id"=>"A1MY0E7E4IHPQT"
			)
		else
			mws_connection = Amazon::MWS::Base.new(
		  	"access_key"=>"AKIAIUCCPIMBYXZOZMXQ",
  			"secret_access_key"=>"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",
  			"merchant_id"=>"A39CG4I2IXB4I2",
  			"marketplace_id"=>US_MKT
  		)
 		end
 		
		response_id = MwsOrder.fetch_orders(mws_connection,cutoff_time,store)
		if !response_id.nil?
			response = MwsResponse.find(response_id)	
			return "Error - #{response.error_code}: #{response.error_message}"
		end
		return "OK"
	end

	def self.fetch_orders(mws_connection,date_since,store)		
		request = MwsRequest.create!(:request_type => "ListOrders", :store => store) 
		response = mws_connection.get_orders_list(      
			:last_updated_after => date_since.iso8601,
			:results_per_page => ORDER_RESULTS_PER_PAGE,
      :fulfillment_channel => ["MFN"], #TODO include AFN?
			:order_status => ["Unshipped", "PartiallyShipped"], #TODO include shipped?
			:marketplace_id => [US_MKT]
		)
		next_token = request.process_response(mws_connection,response,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<MAX_ORDER_PAGES do
			response = mws_connection.get_orders_list_by_next_token(:next_token => next_token)
			n = request.process_response(mws_connection,response,page_num,ORDER_FAIL_WAIT)
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

	# Process XML order into ActiveRecord, and process items on order
	def self.process_order(mws_connection, order, response_id)
		h = MwsHelper.instance_vars_to_hash(order)
		h['mws_response_id'] = response_id
		amz_order = MwsOrder.find_or_create_by_amazon_order_id(order.amazon_order_id)
		amz_order.update_attributes(h)
		return_code = MwsOrder.fetch_order_items(mws_connection, amz_order.amazon_order_id)
		if amz_order.fulfillment_channel == "MFN"
			amz_order.append_to_omx
		end
	end
	
	def self.fetch_order_items(mws_connection, amazon_order_id)		
		request = MwsRequest.create!(:request_type => "ListOrderItems")
		response = mws_connection.get_list_order_items(:amazon_order_id => amazon_order_id)
		next_token = request.process_response(mws_connection, response,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<MAX_ORDER_ITEM_PAGES do
			response = mws_connection.get_list_order_items_by_next_token(:next_token => next_token)
			n = request.process_response(mws_connection,response,page_num,ORDER_ITEM_FAIL_WAIT)
			if n.is_a?(Numeric)
				failure_count += 1
				if failure_count >= MAX_FAILURE_COUNT
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

	def omx_first_name
		a = self.buyer_name.strip.split(/ /)
		a.slice!(a.count-1)
		return a.join(" ")
	end
	
	def omx_last_name
		a = self.buyer_name.strip.split(/ /)
		return a.last
	end
	
	def omx_shipping_method
		if self.ship_service_level == 'Expedited'
			return 11
		elsif self.ship_service_level == 'NextDay'
			return 8
		else
			return 9
		end
	end

	def append_to_omx(params ={})
		omx_connection = RubyOmx::Base.new(
			"http_biz_id" => 'KbmCrvnukGKUosDSTVhWbhrYBlggjNYxGqsujuglguAJhXeKBYDdpwyiRcywvmiUrpHilblPqKgiPAOIfxOfvFOmZLUiNuIfeDrKJxvjeeblkhphUhgPixbvaCJADgIfaDjHWFHXePIFchOjQciNRdrephpJFEfGoUaSFAOcjHmhfgZidlmUsCBdXgmmxIBKhgRjxjJaTcrnCgSkghRWvRwjZgVeVvhHqALceQpdJLphwDlfFXgIHYjCGjCiwZW',
			"udi_auth_token" => '7509fd470db4004809083c0048ef983102d6325b27730421704c1b0899109ab51de58e4dfd80acff062f8042360b5ae01ed4851f50a5d5fe38a10e81c0471a089f20799ddf11c81cc541a10a014fe04e190aee6049efdf97699096bd79db0a9fd04ca90b2a90f63925c223d236fbe97b047c104b900b7e1010fbb39453e0920'
		)

		request = OmxRequest.create!(
			:mws_order_id => self.id,
			:request_type => "UDOA",
			:keycode => "AM01",
			:queue_flag => False,
			:verify_flag => True
		)
		
		omx_line_items = Array.new
		omx_product_amount = 0
		omx_shipping_amount = 0
		self.mws_order_items.each do |i| 			
			omx_line_items << { :item_code => i.clean_sku, :quantity => i.quantity_ordered, :unit_price => i.product_price_per_unit }
			omx_product_amount += (i.product_price_per_unit * i.quantity_ordered)
			omx_shipping_amount += i.sh_total
		end
		
		result = omx_connection.append_order(
			:keycode => request.keycode,
			:order_id => self.amazon_order_id,
			:order_date => self.purchase_date.to_s(:db),
			:queue_flag => request.queue_flag, #TODO must be True when working
			:verify_flag => request.verify_flag, #TODO must be false when working
			:first_name => self.omx_first_name,
			:last_name => self.omx_last_name,
			:address1 => self.address_line_1,
			:address2 => "#{self.address_line_2}#{self.address_line_3}",
			:city => self.city,
			:state => self.state_or_region,
			:zip => self.postal_code,
			:tld => self.country_code,
			:method_code => self.omx_shipping_method,
			:shipping_amount => omx_shipping_amount,
			:gift_wrapping => 'False', #TODO must deal with gift wrapping, line item by line item
			:gift_message => '', #TODO must do gift message, line item by line item
			:phone => self.phone,
			:email => self.buyer_email,
			:line_items => omx_line_items,
			:total_amount => (omx_shipping_amount + omx_product_amount),
			:vendor => "#{self.sales_channel} #{self.fulfillment_channel} #{self.mws_response.mws_request.store}", #TODO must handle multiple channels
			:raw_xml => 0)

		#puts response.body.to_s
		
		raise "Order push was unsuccessful #{response.error_data}" unless response.success == 1 
		
		return response
		response = OmxResponse.create!(:omx_request_id => request.id, :success => result.success, :ordermotion_response_id => result.OMX, :ordermotion_order_number => result.order_number)
		@response = "Success:#{result.success}, omx:#{result.OMX}, order number:#{result.order_number}"
		
	end
	
end