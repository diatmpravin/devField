class Order < ActiveRecord::Base
	belongs_to :response
	has_many :order_items
	validates_uniqueness_of :amazon_order_id
	validates_presence_of :response_id

	def self.get_orders(mws_connection,date_since)
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
		next_token = MwsHelper.process_page(mws_connection,order_pages[0],request,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<max_pages do
			order_pages << mws_connection.get_orders_list_by_next_token(:next_token => next_token)
			n = MwsHelper.process_page(mws_connection,order_pages[page_num],request,page_num, 60)
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
		h['response_id'] = response_id
		amz_order = Order.find_or_create_by_amazon_order_id(order.amazon_order_id)
		amz_order.update_attributes(h)
		return Order.get_order_items(mws_connection, amz_order.amazon_order_id)
	end
	
	def self.get_order_items(mws_connection, amazon_order_id)
		max_pages = 5
		max_failure_count = 2
		
		order_item_pages = Array.new
		request = Request.create!(:request_type => "ListOrderItems")
		order_item_pages << mws_connection.get_list_order_items(:amazon_order_id => amazon_order_id)
		next_token = MwsHelper.process_page(mws_connection, order_item_pages[0], request,0,0)
		if next_token.is_a?(Numeric)
			return next_token
		end
		
		page_num = 1
		failure_count = 0
		while next_token.is_a?(String) && page_num<max_pages do
			order_item_pages << mws_connection.get_list_order_items_by_next_token(:next_token => next_token)
			n = MwsHelper.process_page(mws_connection,order_item_pages[page_num],request,page_num,15)
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
		amz_item = OrderItem.find_or_create_by_amazon_order_item_id_and_order_id(item.amazon_order_item_id,Order.find_by_amazon_order_id(amazon_order_id).id)		
		amz_item.update_attributes(h)
	end
	
end