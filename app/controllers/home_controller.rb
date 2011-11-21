require 'amazon/mws'
require 'slowweb'

US_MKT = "ATVPDKIKX0DER"

class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => ['welcome', 'mws']
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"   
  end
  
  def index
    # get 3 products
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 3})

    # get latest 3 orders
    @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
  
  end

	def mws
		mws_hdo = Amazon::MWS::Base.new(
   		"access_key"=>"AKIAIIPPIV2ZWUHDD5HA",
   		"secret_access_key"=>"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",
   		"merchant_id"=>"A3VX72MEBB21JI",
   		"marketplace_id"=>US_MKT
		)
		
		mws_fd = Amazon::MWS::Base.new(
   		"access_key"=>"AKIAIUCCPIMBYXZOZMXQ",
   		"secret_access_key"=>"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",
   		"merchant_id"=>"A39CG4I2IXB4I2",
   		"marketplace_id"=>US_MKT
		)		

		 
		response_id = get_orders(mws_hdo, Time.current().yesterday)
		if !response_id.nil?
			response = Response.find(response_id)	
			flash[:notice] = "Error - #{response.error_code}: #{response.error_message}"
		end
		@my_orders = Order.all

	end


	def instance_vars_to_hash(obj)
			obj_hash = {}
			obj.instance_variable_names.each do |n|
				m = n.sub('@','')
				if m != 'roxml_references' && m!= 'promotion_ids'
					obj_hash[m.to_sym] = obj.instance_variable_get(n)
				end
			end
			return obj_hash
	end

	# Process a page of orders or order items
	def process_page(mws_connection, page,request,page_num,sleep_if_error)

		# Update the request_id in our request parent object if not set already
		if request.amazon_request_id.nil?
			request.amazon_request_id = page.request_id
			request.save!
		end		

		# Create a new response object, link to the initial request
		response = Response.new(
			:request_type => request.request_type,
			:request_id => request.id, 
			:amazon_request_id => page.request_id,
			:page_num => page_num
		)

		# Check response for error code, fill in remaining details that differ between error and valid response
		if page.accessors.include?("code")
			response.error_code = page.code
			response.error_message = page.message
			response.save!
			sleep sleep_if_error
			return response.id
		else
			response.next_token = page.next_token
			if request.request_type=="ListOrders"
				response.last_updated_before = page.last_updated_before
			end
			if request.request_type=="ListOrderItems"
				response.amazon_order_id = page.amazon_order_id
			end
			response.save!
		end
		
		if request.request_type=="ListOrders"
			page.orders.each do |o|
				r = process_order(mws_connection, o,response.id)
				if r.is_a?(Numeric)
					return r
				end
			end
		elsif request.request_type=="ListOrderItems"		
			page.order_items.each do |i|
				# TODO returns an order_item_id that I'm ignoring, or an error code, impossible to distinguish between the two, however
				process_order_item(i,response.amazon_order_id)
			end
		end
		return response.next_token
	end

	# Process XML order into ActiveRecord, and process items on order
	def process_order(mws_connection, order, response_id)
		h = instance_vars_to_hash(order)
		h['response_id'] = response_id
		amz_order = Order.find_or_create_by_amazon_order_id(order.amazon_order_id)
		amz_order.update_attributes(h)
		
		# need to do error checking, sometimes get_order_items will return an error on a page
		return get_order_items(mws_connection, amz_order.amazon_order_id)
		#return amz_order.id
	end
	
	
	def process_order_item(item, amazon_order_id)
		h = instance_vars_to_hash(item)
		amz_item = OrderItem.find_or_create_by_amazon_order_item_id_and_order_id(item.amazon_order_item_id,Order.find_by_amazon_order_id(amazon_order_id).id)		
		amz_item.update_attributes(h)
	end
	
	def get_orders(mws_connection,date_since)
		max_pages = 1
		max_failure_count = 2

		# Log new request
		request = Request.create!(:request_type => "ListOrders")
		
		# Fetch first 
		order_pages = Array.new
		order_pages << mws_connection.get_orders_list(      
			:last_updated_after => date_since.iso8601,
			:results_per_page => 3,
      :fulfillment_channel => ["MFN"],
			:order_status => ["Unshipped", "PartiallyShipped", "Shipped"],
			:marketplace_id => [US_MKT]
		)
		next_token = process_page(mws_connection,order_pages[0],request,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<max_pages do
			order_pages << mws_connection.get_orders_list_by_next_token(:next_token => next_token)
			n = process_page(mws_connection,order_pages[page_num],request,page_num, 60)
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
	
	def get_order_items(mws_connection, amazon_order_id)
		max_pages = 5
		max_failure_count = 2
		
		order_item_pages = Array.new
		request = Request.create!(:request_type => "ListOrderItems")
		order_item_pages << mws_connection.get_list_order_items(:amazon_order_id => amazon_order_id)
		next_token = process_page(mws_connection, order_item_pages[0], request,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<max_pages do
			order_item_pages << mws_connection.get_list_order_items_by_next_token(:next_token => next_token)
			n = process_page(mws_connection,order_item_pages[page_num],request,page_num,15)
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
	
end