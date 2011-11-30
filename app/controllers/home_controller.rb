#require 'amazon/mws'
#require 'slowweb'
require 'mechanize'
require 'RubyOmx'

class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => ['welcome', 'mws','omx']
  
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
		@my_orders = Order.all
	end
	
	def omx
		omx_connection = RubyOmx::Base.new(
			"http_biz_id" => 'KbmCrvnukGKUosDSTVhWbhrYBlggjNYxGqsujuglguAJhXeKBYDdpwyiRcywvmiUrpHilblPqKgiPAOIfxOfvFOmZLUiNuIfeDrKJxvjeeblkhphUhgPixbvaCJADgIfaDjHWFHXePIFchOjQciNRdrephpJFEfGoUaSFAOcjHmhfgZidlmUsCBdXgmmxIBKhgRjxjJaTcrnCgSkghRWvRwjZgVeVvhHqALceQpdJLphwDlfFXgIHYjCGjCiwZW',
			"udi_auth_token" => '7509fd470db4004809083c0048ef983102d6325b27730421704c1b0899109ab51de58e4dfd80acff062f8042360b5ae01ed4851f50a5d5fe38a10e81c0471a089f20799ddf11c81cc541a10a014fe04e190aee6049efdf97699096bd79db0a9fd04ca90b2a90f63925c223d236fbe97b047c104b900b7e1010fbb39453e0920'
		)
		#response = omx_connection.get_item_info(:raw_xml => 1, :item_code => '243296-083O-JD')
		#response = omx_connection.get_custom_item_info(:raw_xml => 1, :item_code => '243296-083O-JD')
		
		#currency, promotion code AUGUST_03
		response = omx_connection.append_order(
			:keycode => 'AM01',
			:order_id => '003465-ZZ',
			:order_date => '2011-11-29 22:15:10',
			:queue_flag => 'False',
			:verify_flag => 'True',
			:first_name => 'Test',
			:last_name => 'Test',
			:address1 => '251 West 30th St',
			:address2 => 'Apt 12E',
			:city => 'New York',
			:state => 'NY',
			:zip => '10001',
			:tld => 'US',
			:method_code => '9',
			:shipping_amount => '8.75',
			:gift_wrapping => 'True',
			:gift_message => 'Happy Birthday',
			:phone => '+1 212 654 7452',
			:email => 'anonymous@amazon.com',
			:line_items => [
				{ :item_code => '243296-083O-JD', :quantity => '1', :unit_price => '70' },
				{ :item_code => '009-01-G12', :quantity => '2', :unit_price => '65' }
			],
			:total_amount => '208.75',
			:raw_xml => 0)

		#@response = response.body.to_s	
		@response = "Success:#{response.success}, omx:#{response.OMX}, order number:#{response.order_number}"
	end

	#Safilo supplier
	# COGS
	# tax code
	# last updated
	# inventory
	

	def omx_push_order(http_biz_id, udi_auth_token, keycode)

		doc = Nokogiri::XML::Document.new
		udoa_request = doc.add_child(Nokogiri::XML::Node.new "UDOARequest", doc)
		udoa_request['version'] = "2.00"
		udi_parameter = udoa_request.add_child(Nokogiri::XML::Node.new "UDIParameter",udoa_request)
	
		u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
		u['key'] = 'HTTPBizID'
		u.content = http_biz_id
		u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
		u['key'] = 'UDIAuthToken'
		u.content = udi_auth_token
		u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
		u['key'] = 'QueueFlag'
		u.content = 'True'
		u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
		u['key'] = 'Keycode'
		u.content = keycode
		header = udoa_request.add_child(Nokogiri::XML::Node.new 'Header', udoa_request)
		x = header.add_child(Nokogiri::XML::Node.new 'StoreCode', header)	
		x.content = ''
		x = header.add_child(Nokogiri::XML::Node.new 'OrderID', header)	
		x.content = '003465-A'
			
		x = header.add_child(Nokogiri::XML::Node.new 'OrderDate', header)	
		x.content = '2003-04-01 22:15:10'
			
		x = header.add_child(Nokogiri::XML::Node.new 'OriginType', header)	
		x.content = '3'
			
		customer = udoa_request.add_child(Nokogiri::XML::Node.new 'Customer', udoa_request)
		address = customer.add_child(Nokogiri::XML::Node.new 'Address', customer)
		address['type'] = 'BillTo'
		x = address.add_child(Nokogiri::XML::Node.new 'TitleCode', address)	
		x.content = '0'
		x = address.add_child(Nokogiri::XML::Node.new 'Firstname', address)	
		x.content = 'Bill'
		x = address.add_child(Nokogiri::XML::Node.new 'Lastname', address)	
		x.content = 'Thomas'
		x = address.add_child(Nokogiri::XML::Node.new 'Address1', address)	
		x.content = '251 West 30th St'
		x = address.add_child(Nokogiri::XML::Node.new 'Address2', address)	
		x.content = 'Apt 12E'
		x = address.add_child(Nokogiri::XML::Node.new 'City', address)	
		x.content = 'New York'
		x = address.add_child(Nokogiri::XML::Node.new 'State', address)	
		x.content = 'NY'
		x = address.add_child(Nokogiri::XML::Node.new 'ZIP', address)	
		x.content = '10001'
		x = address.add_child(Nokogiri::XML::Node.new 'TLD', address)	
		x.content = 'US'
		
		shipping_info = udoa_request.add_child(Nokogiri::XML::Node.new 'ShippingInformation', udoa_request)
		methodCode = shipping_info.add_child(Nokogiri::XML::Node.new 'MethodCode', shipping_info)
		methodCode.content = '0'
	
		payment_type = udoa_request.add_child(Nokogiri::XML::Node.new 'Payment', udoa_request)
		payment_type['type'] = '1'
		x = payment_type.add_child(Nokogiri::XML::Node.new 'CardNumber',payment_type)
		x.content = '4111111111111111'
		x = payment_type.add_child(Nokogiri::XML::Node.new 'CardExpDateMonth',payment_type)
		x.content = '09'
		x = payment_type.add_child(Nokogiri::XML::Node.new 'CardExpDateYear',payment_type)
		x.content = '2011'
			
		order_detail = udoa_request.add_child(Nokogiri::XML::Node.new 'OrderDetail', udoa_request)
			
		line_item = order_detail.add_child(Nokogiri::XML::Node.new 'LineItem',order_detail )
		x = line_item.add_child(Nokogiri::XML::Node.new 'ItemCode',line_item)
		x.content = 'APPLE'
		x = line_item.add_child(Nokogiri::XML::Node.new 'Quantity',line_item)
		x.content = '1'
		
		return doc.to_xml
	end

end