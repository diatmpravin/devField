require 'rubygems'
require 'roxml'

class OrdersRequest
	include ROXML
	xml_convention :camelcase
	xml_name "Order"

  xml_reader :id, :from => "AmazonOrderId"
end 

class RequestOrdersResponse
  include ROXML
  xml_convention :camelcase
  
  xml_name "ListOrdersResponse"
  result = "ListOrdersResult"
  
	xml_reader :last_updated_before, :in => result, :as => DateTime
	xml_reader :orders, :as => [OrdersRequest], :in => "ListOrdersResult/Orders"
end

lib3 = RequestOrdersResponse.from_xml(File.read("library4.xml"))
puts lib3.last_updated_before.to_s
puts lib3.orders.count.to_s
