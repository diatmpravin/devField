class MwsRequest < ActiveRecord::Base
	has_many :mws_responses
	
	# can get the total time it took by looking at create timestamp - last timestamp in child response
	#def request_time
	#end
	
	def process_response(mws_connection, response_xml,page_num,sleep_if_error)

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
			
			response_xml.orders.each do |o|
				r = MwsOrder.process_order(mws_connection, o,response.id)
				if r.is_a?(Numeric)
					return r
				end
			end
		elsif self.request_type=="ListOrderItems"
			response.amazon_order_id = response_xml.amazon_order_id
			response.save!
			response_xml.order_items.each do |i|
				MwsOrder.process_order_item(i,response.amazon_order_id)
			end
		end
		return response.next_token
	end

	def get_last_date
		self.mws_responses.order('last_updated_before DESC').first.last_updated_before
	end
	
end
