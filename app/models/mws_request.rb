class MwsRequest < ActiveRecord::Base
	belongs_to :store
	has_many :mws_responses, :dependent => :destroy
	
	has_many :sub_requests, :class_name => "MwsRequest"
  belongs_to :parent_request, :class_name => "MwsRequest", :foreign_key => "mws_request_id"
  
	def get_orders_count
		count = 0
		self.mws_responses.each do |r|
			count += r.mws_orders.count
		end
		return count
	end

	def get_orders_without_items_count
		count = 0
		self.mws_responses.each do |r|
			r.mws_orders.each do |o|
				if o.mws_order_items.count == 0
					count += 1		
				end
			end
		end
		return count
	end

	def error_count
		count = 0
		self.sub_requests.each do |r|
			count += r.mws_responses.where('error_message IS NOT NULL').count
		end	
		return count
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
			#shipping_update = 0
			amazon_orders = Array.new
			response_xml.orders.each do |o|
				h = MwsHelper.instance_vars_to_hash(o)
				amz_order = MwsOrder.find_by_amazon_order_id(o.amazon_order_id)
				#if !amz_order.nil? && amz_order.number_of_items_unshipped>0 && h['number_of_items_unshipped'] == 0 
				#	amz_order.set_shipped
				#	shipping_update = 1 # this is likely just a 'shipped' update, so don't pull new items
				#else
					amz_order = MwsOrder.create(:amazon_order_id => o.amazon_order_id)
				#end
				h = MwsHelper.instance_vars_to_hash(o)
				h[:mws_response_id] = response.id
				h[:store_id] = self.store_id
				amz_order.update_attributes(h)
				#if shipping_update == 0
				amazon_orders << amz_order
				#end
			end
			
			# Then loop back to get item detail behind each order
			sleep_time = MwsOrder::get_sleep_time_per_order(amazon_orders.count)
			amazon_orders.each do |amz_order|
				sleep sleep_time
				r = amz_order.process_order(mws_connection)
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
