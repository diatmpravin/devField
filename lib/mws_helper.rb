class MwsHelper
	
	def self.instance_vars_to_hash(obj)
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
	def self.process_page(mws_connection, page,request,page_num,sleep_if_error)

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
				r = Order.process_order(mws_connection, o,response.id)
				if r.is_a?(Numeric)
					return r
				end
			end
		elsif request.request_type=="ListOrderItems"		
			page.order_items.each do |i|
				Order.process_order_item(i,response.amazon_order_id)
			end
		end
		return response.next_token
	end
	
end