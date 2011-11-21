require 'rubygems'
require 'roxml'

#class OrdersRequest
#	include ROXML
#	xml_convention :camelcase
#	xml_name :order

#  xml_reader :id, :from => "AmazonOrderId"
#end 

#class RequestOrdersResponse
#  include ROXML
#  xml_convention :camelcase
  
#  xml_name "ListOrdersResponse"
#  result = "ListOrdersResult"
  
#	xml_reader :last_updated_before, :in => result, :as => DateTime
#	xml_reader :orders, :as => [OrdersRequest], :in => "Orders"
#end

class OrdersRequest
  include ROXML
  xml_convention :camelcase
  xml_name "Order"

  #xml_accessor :isbn, :from => "@ISBN" # attribute with name 'ISBN'
  xml_reader :id, :from => "AmazonOrderId"
  xml_reader :purchase_date, :as => DateTime
  xml_reader :last_update_date, :as => DateTime
  xml_reader :order_status
  xml_reader :sales_channel
  xml_reader :amount, :in => "xmlns:OrderTotal", :as => Float
  xml_reader :currency_code, :in => "xmlns:OrderTotal"         
	xml_reader :address_line_1, :in => "xmlns:ShippingAddress" 

end

class RequestOrdersResponse
  include ROXML
  xml_convention :camelcase
  xml_name "ListOrdersResponse"
  result = "ListOrdersResult"

  xml_reader :last_updated_before, :as => DateTime, :in => "xmlns:ListOrdersResult"
  xml_reader :orders, :as => [OrdersRequest], :in => "xmlns:ListOrdersResult/xmlns:Orders" # by default roxml searches for books for in <book> child nodes, then, if none are present, in ./books/book children
end

#book = Book.new
#book.isbn = "0201710897"
#book.title = "The PickAxe"
#book.description = "Best Ruby book out there!"
#book.author = "David Thomas, Andrew Hunt, Dave Thomas"

#lib = Library.new
#lib.name = "Favorite Books"
#lib.books = [book]

#doc = Nokogiri::XML::Document.new
#doc.root = lib.to_xml
#open("library.xml", 'w') do |file|
#  file << doc.serialize
#end

lib2 = RequestOrdersResponse.from_xml(File.read("OrdersXML.xml"))
puts lib2.last_updated_before.to_s
puts lib2.orders.count.to_s
puts lib2.orders[0].id
puts lib2.orders[1].id
puts lib2.orders[0].amount
puts lib2.orders[0].currency_code
puts lib2.orders[0].address_line_1


#lib3 = RequestOrdersResponse.from_xml(File.read("library4.xml"))
#puts lib3.last_updated_before.to_s
#puts lib3.orders.count.to_s
