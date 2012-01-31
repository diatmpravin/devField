# encoding: utf-8

require 'amazon/mws'
require 'RubyOmx'

class MwsOrder < ActiveRecord::Base
	belongs_to :mws_response
	belongs_to :store
	has_many :mws_order_items, :dependent => :destroy
	has_many :omx_requests
	has_many :omx_responses, :through => :omx_requests
	validates_uniqueness_of :amazon_order_id
	validates_presence_of :mws_response_id
	validates_presence_of :purchase_date
	validates_associated :store
	
	MAX_ORDER_ITEM_PAGES = 20
	MAX_FAILURE_COUNT = 1
	ORDER_ITEM_FAIL_WAIT = 60
		
	#@@state_lookup = {'AK' => 'AK','AL' => 'AL','ALABAMA' => 'AL','ALASKA' => 'AK','AR' => 'AR','ARIZONA' => 'AZ','ARKANSAS' => 'AK','AZ' => 'AZ','CA' => 'CA','CA.' => 'CA','CALIFORNIA' => 'CA','CO' => 'CO','COLORADO' => 'CO','CONNECTICUT' => 'CT','CT' => 'CT','D.F.' => 'DF','DISTRICT OF COLUMBIA' => 'DC','DC' => 'DC','DELAWARE' => 'DE','DE' => 'DE','DF' => 'DF','DISTRITO FEDERAL' => 'DF','FL' => 'FL','FL.' => 'FL','FLORIDA' => 'FL','GA' => 'GA','GEORGIA' => 'GA','HAWAII' => 'HI','HI' => 'HI','IA' => 'IA','ID' => 'ID','IDAHO' => 'ID','IL' => 'IL','ILLINOIS' => 'IL','IN' => 'IN','INDIANA' => 'IN','IOWA' => 'IA','KANSAS' => 'KS','KENTUCKY' => 'KY', 'KS' => 'KS','KY' => 'KY','LA' => 'LA','LA.' => 'LA','LOUISIANA' => 'LA','MA' => 'MA','MAINE' => 'ME','MARYLAND' => 'MD','MASSACHUSETTS' => 'MA','MD' => 'MD','ME' => 'ME','MI' => 'MI','MICHIGAN' => 'MI','MINNESOTA' => 'MN','MISSISSIPPI' => 'MS','MISSOURI' => 'MO','MN' => 'MN','MO' => 'MO','MONTANA' => 'MT','MS' => 'MS','MT' => 'MT','N.Y.' => 'NY','NC' => 'NC','ND' => 'ND','NEBRASKA' => 'NE','NE' => 'NE','NEVADA' => 'NV','NEW HAMPSHIRE' => 'NH','NEW JERSEY' => 'NJ','NEW MEXICO' => 'NM','NEW YORK' => 'NY','NH' => 'NH','NJ' => 'NJ','NM' => 'NM','NORTH CAROLINA' => 'NC','NV' => 'NV','NY' => 'NY','OH' => 'OH','OHIO' => 'OH','OK' => 'OK','OKLAHOMA' => 'OK','OR' => 'OR','OREGON' => 'OR','PA' => 'PA','PENNSYLVANIA' => 'PA','PR' => 'PR','PUERTO RICO' => 'PR','RHODE ISLAND' => 'RI','RI' => 'RI','SC' => 'SC','SD' => 'SD','SOUTH CAROLINA' => 'SC','SOUTH DAKOTA' => 'SD', 'TENNESSEE' => 'TN','TEXAS' => 'TX','TN' => 'TN','TX' => 'TX','UT' => 'UT','UTAH' => 'UT','VA' => 'VA','VIRGINIA' => 'VA','VERMONT' => 'VT','VT' => 'VT','WA' => 'WA','WASHINGTON' => 'WA','WEST VIRGINIA' => 'WV', 'WI' => 'WI','WISCONSIN' => 'WI','WV' => 'WV','WYOMING' => 'WY','WY' => 'WY', 'AUSTRALIAN CAPITAL TERRITORY' => 'ACT','NEW SOUTH WALES' => 'NSW','NORTHERN TERRITORY' => 'NT','QUEENSLAND' => 'QLD','SOUTH AUSTRALIA' => 'SA','TASMANIA' => 'TAS','VICTORIA' => 'VIC','WESTERN AUSTRALIA' => 'WA','ALBERTA' => 'AB','BRITISH COLUMBIA' => 'BC','MANITOBA' => 'MB','NEW BRUNSWICK' => 'NB','NEWFOUNDLAND & LABRADOR' => 'NL','NORTHWEST TERRITORIES' => 'NT','NOVA SCOTIA' => 'NS','NUNAVUT' => 'NU','ONTARIO' => 'ON','PRINCE EDWARD ISLAND' => 'PE','QUEBEC' => 'QC','SASKATCHEWAN' => 'SK','YUKON' => 'YT','BRITISH COLUMBIA' => 'BC','ALBERTA' => 'AB','BRITISH COLUMBIA' => 'BC','MANITOBA' => 'MB','NEW BRUNSWICK' => 'NB','NEWFOUNDLAND & LABRADOR' => 'NL','NORTHWEST TERRITORIES' => 'NT','NOVA SCOTIA' => 'NS','NUNAVUT' => 'NU','ONTARIO' => 'ON','PRINCE EDWARD ISLAND' => 'PE','QUEBEC' => 'QC','SASKATCHEWAN' => 'SK','YUKON' => 'YT','ANDAMAN AND NICOBAR ISLANDS' => 'AN','ANDHRA PRADESH' => 'AP','ARUNACHAL PRADESH' => 'AR','ASSAM' => 'AS','BIHAR' => 'BR','CHANDIGARH' => 'CHD','DADRA AND NAGAR HAVELI' => 'DNH','DAMAN AND DIU' => 'DD','DELHI' => 'DEL','GOA' => 'GOA','GUJARAT' => 'GUJ','HARYANA' => 'HR','HIMACHAL PRADESH' => 'HP','JAMMU AND KASHMIR' => 'JK','KARNATAKA' => 'KRN','KERALA' => 'KER','LAKSHADWEEP' => 'LKP','MADHYA PRADESH' => 'MP','MAHARASHTRA' => 'MAH','MANIPUR' => 'MNP','MEGHALAYA' => 'MEG','MIZORAM' => 'MIZ','NAGALAND' => 'NLD','ORISSA' => 'OR','PONDICHERRY' => 'PDY','PUNJAB' => 'PU','RAJASTHAN' => 'RAJ','SIKKIM' => 'SKM','TAMIL NADU' => 'TN','TRIPURA' => 'TRP','UTTAR PRADESH' => 'UP','UTTARANCHAL' => 'UA','WEST BENGAL' => 'WB','GB' => 'UK', 'ACRE' => 'AC','ALAGOAS' => 'AL','AMAPÁ' => 'AP','AMAZONAS' => 'AM','BAHÍA' => 'BA','CEARÁ' => 'CE','DF (FEDERAL DISTRICT)' => 'DF','ESPIRITO SANTO' => 'ES','GOIÁS' => 'GO','MARANHÃO' => 'MA','MATO GROSSO' => 'MT','MATO GROSSO DO SUL' => 'MS','MINAS GERAÍS' => 'MG','PARÁ' => 'PA','PARAÍBA' => 'PB','PARANÁ' => 'PR','PERNAMBUCO' => 'PE','PIAUÍ' => 'PI','RIO DE JANEIRO' => 'RJ','RIO GRANDE DO NORTE' => 'RN','RIO GRANDE DO SUL' => 'RS','RONDÔNIA' => 'RO','RORAIMA' => 'RR','SANTA CATARINA' => 'SC','SÃO PAULO' => 'SP','SERGIPE' => 'SE','TOCANTINS' => 'TO', 'ACT' => 'ACT','NSW' => 'NSW','NT' => 'NT','QLD' => 'QLD','SA' => 'SA','TAS' => 'TAS','VIC' => 'VIC','WA' => 'WA','AB' => 'AB','BC' => 'BC','MB' => 'MB','NB' => 'NB','NL' => 'NL','NT' => 'NT','NS' => 'NS','NU' => 'NU','ON' => 'ON','PE' => 'PE','QC' => 'QC','SK' => 'SK','YT' => 'YT','BC' => 'BC','AB' => 'AB','BC' => 'BC','MB' => 'MB','NB' => 'NB','NL' => 'NL','NT' => 'NT','NS' => 'NS','NU' => 'NU','ON' => 'ON','PE' => 'PE','QC' => 'QC','SK' => 'SK','YT' => 'YT','AN' => 'AN','AP' => 'AP','AR' => 'AR','AS' => 'AS','BR' => 'BR','CHD' => 'CHD','DNH' => 'DNH','DD' => 'DD','DEL' => 'DEL','GOA' => 'GOA','GUJ' => 'GUJ','HR' => 'HR','HP' => 'HP','JK' => 'JK','KRN' => 'KRN','KER' => 'KER','LKP' => 'LKP','MP' => 'MP','MAH' => 'MAH','MNP' => 'MNP','MEG' => 'MEG','MIZ' => 'MIZ','NLD' => 'NLD','OR' => 'OR','PDY' => 'PDY','PU' => 'PU','RAJ' => 'RAJ','SKM' => 'SKM','TN' => 'TN','TRP' => 'TRP','UP' => 'UP','UA' => 'UA','WB' => 'WB','UK' => 'UK','AC' => 'AC','AL' => 'AL','AP' => 'AP','AM' => 'AM','BA' => 'BA','CE' => 'CE','DF' => 'DF','ES' => 'ES','GO' => 'GO','MA' => 'MA','MT' => 'MT','MS' => 'MS','MG' => 'MG','PA' => 'PA','PB' => 'PB','PR' => 'PR','PE' => 'PE','PI' => 'PI','RJ' => 'RJ','RN' => 'RN','RS' => 'RS','RO' => 'RO','RR' => 'RR','SC' => 'SC','SP' => 'SP','SE' => 'SE','TO' => 'TO','AGUASCALIENTES' => 'AGS','BAJA CALIFORNIA NORTE' => 'BCN','BAJA CALIFORNIA SUR' => 'BCS','CAMPECHE' => 'CAM','CHIAPAS' => 'CHIS','CHIHUAHUA' => 'CHIH','COAHUILA' => 'COAH','COLIMA' => 'COL','DISTRITO FEDERAL' => 'DF','DURANGO' => 'DGO','GUANAJUATO' => 'GTO','GUERRERO' => 'GRO','HIDALGO' => 'HGO','JALISCO' => 'JAL','MÉXICO (ESTADO DE)' => 'MEX','MICHOACÁN' => 'MICH','MORELOS' => 'MOR','NAYARIT' => 'NAY','NUEVO LEÓN' => 'NL','OAXACA' => 'OAX','PUEBLA' => 'PUE','QUERÉTARO' => 'QRO','QUINTANA ROO' => 'QROO','SAN LUIS POTOSÍ' => 'SLP','SINALOA' => 'SIN','SONORA' => 'SON','TABASCO' => 'TAB','TAMAULIPAS' => 'TAMPS','TLAXCALA' => 'TLAX','VERACRUZ' => 'VER','YUCATÁN' => 'YUC','ZACATECAS' => 'ZAC','AGS' => 'AGS','BCN' => 'BCN','BCS' => 'BCS','CAM' => 'CAM','CHIS' => 'CHIS','CHIH' => 'CHIH','COAH' => 'COAH','COL' => 'COL','DF' => 'DF','DGO' => 'DGO','GTO' => 'GTO','GRO' => 'GRO','HGO' => 'HGO','JAL' => 'JAL','MEX' => 'MEX','MICH' => 'MICH','MOR' => 'MOR','NAY' => 'NAY','NL' => 'NL','OAX' => 'OAX','PUE' => 'PUE','QRO' => 'QRO','QROO' => 'QROO','SLP' => 'SLP','SIN' => 'SIN','SON' => 'SON','TAB' => 'TAB','TAMPS' => 'TAMPS','TLAX' => 'TLAX','VER' => 'VER','YUC' => 'YUC','ZAC' => 'ZAC' }
	#def self.add_states
	#	@@state_lookup2.each do|raw,clean|
  #		State.create(:raw_state => raw, :clean_state => clean)
	#	end
	#end

	def self.get_unmatched_skus
		where(:id => MwsOrderItem.get_unmatched_skus)
	end

	def self.search(search)
		# get sub_matches from order_items
		o1 = MwsOrderItem.search(search).collect { |o| o.mws_order_id }
			
		# get direct matches at order level
		fields = [ 'amazon_order_id', 'seller_order_id', 'address_line_1', 'address_line_2', 'address_line_3', 'city', 'state_or_region', 'country_code', 'postal_code', 'buyer_name', 'buyer_email', 'shipment_service_level_category', 'name']
		bind_vars = MwsHelper::search_helper(fields, search)
		o2 = select('id').where(bind_vars).collect { |o| o.id }
			
		# combine the two arrays of IDs and remove duplicates, and return all relevant records
		where(:id => o1 | o2)
	end

	# return a value between 0 and 6 for the number of seconds to delay between OrderItem requests to Amazon
	def self.get_sleep_time_per_order(order_count)
		if order_count.is_a?(Numeric) && order_count>0
			sleep_time = 0.0
			request_buffer = 15.0
			refresh_interval = 6.0
			sleep_time = (([order_count - request_buffer, 0.0].max) / order_count)*refresh_interval
			return sleep_time
		else
			return 0
		end
	end

	def set_shipped
		self.mws_order_items.each do |i|
			i.set_shipped
		end
	end

	def get_item_quantity_ordered
		q = 0
		q += self.number_of_items_unshipped ? self.number_of_items_unshipped : 0
		q += self.number_of_items_shipped ? self.number_of_items_shipped : 0
		return q
	end
	
	def get_item_quantity_loaded
		q = 0
		self.mws_order_items.each do |i|
			q += i.quantity_ordered
		end
		return q
	end

	def get_item_quantity_missing
		return get_item_quantity_ordered - get_item_quantity_loaded
	end
	
	def get_item_price
		total = 0
		self.mws_order_items.each do |i|
			total += i.get_item_price
		end
		return total
	end

	def get_ship_price
		total = 0
		self.mws_order_items.each do |i|
			total += i.get_ship_price
		end
		return total		
	end
	
	def get_gift_price
		total = 0
		self.mws_order_items.each do |i|
			total += i.get_gift_price
		end
		return total		
	end

	def get_total_price
		total = 0
		self.mws_order_items.each do |i|
			total += i.get_total_price
		end
		return total		
	end

	def pushed_to_omx?
		pushed = "Error"
		if self.fulfillment_channel == "AFN"
			return 'N/A'
		elsif (self.order_status != 'Unshipped' && self.order_status != 'PartiallyShipped')
			return 'Shipped'
		end
		self.omx_responses.each do |resp|
			if !resp.ordermotion_order_number.nil? && resp.ordermotion_order_number != ''
				pushed = 'Yes'
			elsif resp.error_data.nil? || resp.error_data == ''
				pushed = 'No'
			elsif !resp.error_data.match(/The provided Order ID has already been used for the provided store/).nil?
				pushed = 'Dup'
			end
		end
		return pushed
	end

	def reprocess_order
		store = self.store
		if store.mws_connection.nil?
			logger.debug "store mws connection is nil, store is #{store.name}"
		else
			return process_order(store.mws_connection)
		end 
	end

	# Process XML order into ActiveRecord, and process items on order
	def process_order(mws_connection)
		return_code = fetch_order_items(mws_connection)

		#TODO if reprocessing, use the update OMX API call rather than append
		if get_item_quantity_missing == 0 && self.fulfillment_channel == "MFN" && (self.order_status == 'Unshipped' || self.order_status == 'PartiallyShipped')
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
		h = MwsHelper.instance_vars_to_hash(item)
		h[:mws_response_id] = response_id
		h[:mws_order_id] = self.id
		h[:amazon_order_id] = self.amazon_order_id		
		amz_item = MwsOrderItem.find_or_create_by_amazon_order_item_id(h[:amazon_order_item_id])
		amz_item.update_attributes(h)
	end

	def omx_first_name
		if self.name.nil?
			return '[Blank]'
		end
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
		if self.name.nil?
			return '[Blank]'
		end
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
		elsif self.shipment_service_level_category == 'SecondDay'
			return 20
		else
			return 9
		end
	end

	def omx_state
		if self.state_or_region.nil?
			return nil
		else
			state = State.find_by_raw_state(self.state_or_region.upcase)
			if state.nil?
				State.create(:raw_state => self.state_or_region, :clean_state => self.state_or_region)
				return self.state_or_region
			else
				return state.clean_state
			end
		end  
	end

	def omx_country
		if self.country_code.nil?
			return nil
		else
			country = State.find_by_raw_state(self.country_code.upcase)
			if country.nil?
				State.create(:raw_state => self.country_code, :clean_state => self.country_code)
				return self.country_code
			else
				return country.clean_state
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
		self.mws_order_items.each do |i| 
			if !i.gift_wrap_level.nil? && i.gift_wrap_level != ''
				return i.gift_wrap_level
			end
		end
		return nil
	end
	
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
			omx_line_items << { :item_code => i.clean_sku, :quantity => i.quantity_ordered, :unit_price => i.get_item_price_per_unit }
			omx_product_amount += (i.get_item_price_per_unit * i.quantity_ordered)
			omx_shipping_amount += (i.get_ship_price + i.get_gift_price)
		end 
		
		address1 = self.address_line_1
		address2 = nil
		if address1.nil?
			address1 = "#{self.address_line_2} #{self.address_line_3}"
		else
			address2 = "#{self.address_line_2} #{self.address_line_3}"
		end
		
		result = omx_connection.append_order(
			:keycode => request.keycode,
			:order_id => self.amazon_order_id,
			:order_date => self.purchase_date.to_s(:db),
			:queue_flag => request.queue_flag,
			:verify_flag => request.verify_flag,
			:first_name => self.omx_first_name,
			:last_name => self.omx_last_name,
			:address1 => address1,
			:address2 => address2,
			:city => self.city,
			:state => omx_state,
			:zip => self.postal_code,
			:tld => omx_country,
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
			omx_response.error_data = result.error_data.strip
			logger.debug "Order push was unsuccessful #{omx_response.error_data}"
		else
			omx_response.ordermotion_response_id = result.OMX
			omx_response.ordermotion_order_number = result.order_number
			logger.debug "Success:#{result.success}, omx:#{result.OMX}, order number:#{result.order_number}"	
		end
		omx_response.save! 
		return omx_response
	end
	
end