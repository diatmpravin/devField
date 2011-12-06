require 'amazon/mws'
require 'RubyOmx'

class MwsOrder < ActiveRecord::Base
	belongs_to :mws_response
	belongs_to :store
	has_many :mws_order_items, :dependent => :destroy
	has_many :omx_requests
	validates_uniqueness_of :amazon_order_id
	validates_presence_of :mws_response_id
	
	MAX_ORDER_ITEM_PAGES = 10
	MAX_FAILURE_COUNT = 3
	ORDER_ITEM_FAIL_WAIT = 20
		
	@@state_lookup = {'AK' => 'AK','AL' => 'AL','ALABAMA' => 'AL','ALASKA' => 'AK','AR' => 'AR','ARIZONA' => 'AZ','ARKANSAS' => 'AK','AZ' => 'AZ','CA' => 'CA','CA.' => 'CA','CALIFORNIA' => 'CA','CO' => 'CO','COLORADO' => 'CO','CONNECTICUT' => 'CT','CT' => 'CT','D.F.' => 'DF','DISTRICT OF COLUMBIA' => 'DC','DC' => 'DC','DE' => 'DE','DF' => 'DF','DISTRITO FEDERAL' => 'DF','FL' => 'FL','FL.' => 'FL','FLORIDA' => 'FL','GA' => 'GA','GEORGIA' => 'GA','HAWAII' => 'HI','HI' => 'HI','IA' => 'IA','ID' => 'ID','IDAHO' => 'ID','IL' => 'IL','ILLINOIS' => 'IL','IN' => 'IN','INDIANA' => 'IN','IOWA' => 'IA','KANSAS' => 'KS','KENTUCKY' => 'KY', 'KS' => 'KS','KY' => 'KY','LA' => 'LA','LA.' => 'LA','LOUISIANA' => 'LA','MA' => 'MA','MAINE' => 'ME','MARYLAND' => 'MD','MASSACHUSETTS' => 'MA','MD' => 'MD','ME' => 'ME','MI' => 'MI','MICHIGAN' => 'MI','MINNESOTA' => 'MN','MISSISSIPPI' => 'MS','MISSOURI' => 'MO','MN' => 'MN','MO' => 'MO','MONTANA' => 'MT','MS' => 'MS','MT' => 'MT','N.Y.' => 'NY','NC' => 'NC','ND' => 'ND','NE' => 'NE','NEVADA' => 'NV','NEW HAMPSHIRE' => 'NH','NEW JERSEY' => 'NJ','NEW MEXICO' => 'NM','NEW YORK' => 'NY','NH' => 'NH','NJ' => 'NJ','NM' => 'NM','NORTH CAROLINA' => 'NC','NV' => 'NV','NY' => 'NY','OH' => 'OH','OHIO' => 'OH','OK' => 'OK','OKLAHOMA' => 'OK','OR' => 'OR','OREGON' => 'OR','PA' => 'PA','PENNSYLVANIA' => 'PA','PR' => 'PR','PUERTO RICO' => 'PR','RHODE ISLAND' => 'RI','RI' => 'RI','SC' => 'SC','SD' => 'SD','SOUTH CAROLINA' => 'SC','TENNESSEE' => 'TN','TEXAS' => 'TX','TN' => 'TN','TX' => 'TX','UT' => 'UT','UTAH' => 'UT','VA' => 'VA','VIRGINIA' => 'VA','VT' => 'VT','WA' => 'WA','WASHINGTON' => 'WA','WEST VIRGINIA' => 'WV', 'WI' => 'WI','WISCONSIN' => 'WI','WV' => 'WV','WY' => 'WY'}

	def self.update_all_store_ids
		orders = MwsOrder.all
		orders.each do |o|
			o.store_id = o.mws_response.mws_request.store_id
			o.save!
		end
	end

	def item_quantity
		q = 0
		self.mws_order_items.each do |i|
			q += i.quantity_ordered
		end
		return q
	end


	def pushed_to_omx?
		pushed = "Error"
		self.omx_requests.each do |req|
			resp = req.omx_response
			if !resp.nil?
				if !resp.ordermotion_order_number.nil? && resp.ordermotion_order_number != ''
					pushed = "Yes"
				elsif resp.error_data.nil? || resp.error_data == ''
					pushed = "No"
				end
			end
		end
		return pushed
	end

	# Process XML order into ActiveRecord, and process items on order
	def process_order(mws_connection)		
		return_code = fetch_order_items(mws_connection)
		#raise Exception unless (self.item_quantity == (self.number_of_items_unshipped + self.number_of_items_shipped))
		if self.fulfillment_channel == "MFN"
			append_to_omx
		end
		return return_code
	end
	
	def fetch_order_items(mws_connection)		
		parent_request = self.mws_response.mws_request
		request = MwsRequest.create!(:request_type => "ListOrderItems", :store_id => parent_request.store_id, :mws_request_id => parent_request.id)
		response = mws_connection.get_list_order_items(:amazon_order_id => self.amazon_order_id)
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

	def process_order_item(item, response_id)
		amz_item = MwsOrderItem.find_or_create_by_amazon_order_item_id_and_mws_order_id_and_amazon_order_id(item.amazon_order_item_id,self.id,self.amazon_order_id)		
		h = MwsHelper.instance_vars_to_hash(item)
		h['mws_response_id'] = response_id
		amz_item.update_attributes(h)
	end

	def omx_first_name
		a = self.name.strip.split(/ /)
		a.slice!(a.count-1)
		first_name = a.join(" ")
		if first_name.nil? || first_name == ''
			return '[Blank]'
		else
			return first_name
		end
	end
	
	def omx_last_name
		a = self.name.strip.split(/ /)
		last_name = a.last
		if last_name.nil? || last_name == ''
			return '[Blank]'
		else
			return last_name
		end
	end
	
	def omx_shipping_method
		if self.shipment_service_level_category == 'Expedited'
			return 11
		elsif self.shipment_service_level_category == 'NextDay'
			return 8
		else
			return 9
		end
	end

	#TODO change this to work off a table, add missing items to the table for mapping
	def omx_state
		if self.state_or_region.nil?
			return nil
		else
			state = @@state_lookup[self.state_or_region.upcase]
			if state.nil?
				return self.state_or_region
			else
				return state
			end
		end  
	end
	
	#TODO must deal with gift wrapping, line item by line item
	def omx_gift_wrapping
		if !omx_gift_message.nil? || !omx_gift_wrap_level.nil? 
			return 'True'
		else
			return 'False'
		end
	end

	#TODO gift message should be line by line item
	def omx_gift_wrap_level
		items = self.mws_order_items
		items.each do |i| 
			if !i.gift_wrap_level.nil? && i.gift_wrap_level != ''
				return i.gift_wrap_level
			end
		end
		return nil
	end
	
	#TODO gift message should be line by line item
	def omx_gift_message
		items = self.mws_order_items
		items.each do |i| 
			if !i.gift_message_text.nil? && i.gift_message_text != ''
				return i.gift_message_text
			end
		end
		return nil
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
			:vendor => "",
			:store_code => "#{self.sales_channel} #{self.fulfillment_channel} #{self.mws_response.mws_request.store.name}",
			:queue_flag => self.mws_response.mws_request.store.queue_flag,
			:verify_flag => self.mws_response.mws_request.store.verify_flag
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
			:queue_flag => request.queue_flag,
			:verify_flag => request.verify_flag,
			:first_name => self.omx_first_name,
			:last_name => self.omx_last_name,
			:address1 => self.address_line_1,
			:address2 => "#{self.address_line_2} #{self.address_line_3}",
			:city => self.city,
			:state => self.omx_state,
			:zip => self.postal_code,
			:tld => self.country_code,
			:method_code => self.omx_shipping_method,
			:shipping_amount => omx_shipping_amount,
			:gift_wrapping => omx_gift_wrapping, 
			:gift_message => omx_gift_message,
			:phone => self.phone,
			:email => self.buyer_email,
			:line_items => omx_line_items,
			:total_amount => (omx_shipping_amount + omx_product_amount),
			:store_code => request.store_code,
			:vendor => request.vendor, 
			:raw_xml => 0)

		# for raw_xml option
		 #puts response.body.to_s

		omx_response = OmxResponse.create!(:omx_request_id => request.id, :success => result.success)		
		if omx_response.success != 1
			logger.debug "Order push was unsuccessful #{result.error_data}"
			omx_response.error_data = result.error_data
		else
			logger.debug "Success:#{result.success}, omx:#{result.OMX}, order number:#{result.order_number}"
			omx_response.ordermotion_response_id = result.OMX
			omx_response.ordermotion_order_number = result.order_number	
		end
		omx_response.save! 
		return omx_response
	end
	
end