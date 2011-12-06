class MwsRequest < ActiveRecord::Base
	belongs_to :store
	has_many :mws_responses, :dependent => :destroy
	
	has_many :sub_requests, :class_name => "MwsRequest"
  belongs_to :parent_request, :class_name => "MwsRequest", :foreign_key => "mws_request_id"
  
	
	# can get the total time it took by looking at create timestamp - last timestamp in child response
	#def request_time
	#end

	def self.update_all_parent_ids
		requests = MwsRequest.order('created_at ASC')
		request_count = requests.count
		i = 0
		current_parent_id = nil
		
		while i < request_count do
			if requests[i].request_type == 'ListOrders'
				current_parent_id = requests[i].id
			else
				requests[i].parent_mws_request_id = current_parent_id
				requests[i].save!
			end
			i += 1
		end
	end

	def error_count
		return self.mws_responses.where('error_message IS NOT NULL').count
	end
	
	def process_response(mws_connection,response_xml,page_num,sleep_if_error)

		# Update the request_id in our request parent object if not set already
		if self.amazon_request_id.nil?
			self.amazon_request_id = response_xml.request_id
			self.save!
		end		

		# Create a new response object, link to the initial request
		response = MwsResponse.new(
			:request_type => self.request_type,
			:mws_request_id => self.id, 
			:amazon_request_id => response_xml.request_id,
			:page_num => page_num
		)
		
		if response_xml.accessors.include?("code")
			response.error_code = response_xml.code
			response.error_message = response_xml.message
			response.save!
			sleep sleep_if_error
			return response.id
		end
			
		response.next_token = response_xml.next_token
	
		if self.request_type=="ListOrders"
			response.last_updated_before = response_xml.last_updated_before
			response.save!
			
			# Process all orders first
			amazon_orders = Array.new
			response_xml.orders.each do |o|
				amz_order = MwsOrder.find_or_create_by_amazon_order_id(o.amazon_order_id)
				h = MwsHelper.instance_vars_to_hash(o)
				h['mws_response_id'] = response.id
				h['store_id'] = self.store_id
				amz_order.update_attributes(h)
				amazon_orders << amz_order
			end
			
			# Then loop back to get item detail behind each order
			amazon_orders.each do |amz_order|
				r = amz_order.process_order(mws_connection)
				#if r.is_a?(Numeric)
				#	return r
				#end
			end
		elsif self.request_type=="ListOrderItems"
			response.amazon_order_id = response_xml.amazon_order_id
			response.save!
			amz_order = MwsOrder.find_by_amazon_order_id(response.amazon_order_id)
			response_xml.order_items.each do |i|
				amz_order.process_order_item(i,response.id)
			end
		end
		return response.next_token
	end

	def get_last_date
		self.mws_responses.order('last_updated_before DESC').first.last_updated_before
	end
	
end
