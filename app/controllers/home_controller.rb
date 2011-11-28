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
	#HTTP Biz Id: 'KbmCrvnukGKUosDSTVhWbhrYBlggjNYxGqsujuglguAJhXeKBYDdpwyiRcywvmiUrpHilblPqKgiPAOIfxOfvFOmZLUiNuIfeDrKJxvjeeblkhphUhgPixbvaCJADgIfaDjHWFHXePIFchOjQciNRdrephpJFEfGoUaSFAOcjHmhfgZidlmUsCBdXgmmxIBKhgRjxjJaTcrnCgSkghRWvRwjZgVeVvhHqALceQpdJLphwDlfFXgIHYjCGjCiwZW'
	#Merchant Id: '{v1y3-g3o3-y4t4-d1g8}'
	omx_connection = RubyOmx::Base.new(
		'udi_auth_token'=>'724b06e605866042f2087f404a247275553956b2d6df04d0704763097510de3e12ae4722fbb431390fc3e042d80a03f031306e0a30c245e8c6210b6ef0454f0b84c089eef5c64d8dbbe3a7ae09abf0427b0894206677546fa3b07177d7f301ebb04757099f70f9c43e995f395db5224b08a3e041cb0a2d509da20ec1d8d5d37'
	)
	
	doc = Nokogiri::XML::Document.new
	udoa_request = doc.add_child(Nokogiri::XML::Node.new "UDOARequest", doc)
	udoa_request['version'] = "2.00"
	udi_parameter = udoa_request.add_child(Nokogiri::XML::Node.new "UDIParameter",udoa_request)

	#<Parameter key="UDIAuthToken">YourToken</Parameter>
	u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
	u['key'] = 'UDIAuthToken'
	u.content = '724b06e605866042f2087f404a247275553956b2d6df04d0704763097510de3e12ae4722fbb431390fc3e042d80a03f031306e0a30c245e8c6210b6ef0454f0b84c089eef5c64d8dbbe3a7ae09abf0427b0894206677546fa3b07177d7f301ebb04757099f70f9c43e995f395db5224b08a3e041cb0a2d509da20ec1d8d5d37'
	u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
	u['key'] = 'QueueFlag'
	u.content = 'True'
	u = udi_parameter.add_child(Nokogiri::XML::Node.new "Parameter",udi_parameter)
	u['key'] = 'Keycode'
	u.content = 'JTESTKEY'
	header = udoa_request.add_child(Nokogiri::XML::Node.new 'Header', udoa_request)
	x = header.add_child(Nokogiri::XML::Node.new 'StoreCode', header)	
	x.content = 'WEBSTORE01'
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

	response = omx_connection.push_order(      
		:xml_input => doc.to_xml,
		:raw_xml => 1
	)
	@response = response.to_s		
	end

end