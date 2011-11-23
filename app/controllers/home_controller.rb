require 'amazon/mws'
require 'slowweb'

US_MKT = "ATVPDKIKX0DER"

class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => ['welcome', 'mws']
  
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
		mws_hdo = Amazon::MWS::Base.new(
   		"access_key"=>"AKIAIIPPIV2ZWUHDD5HA",
   		"secret_access_key"=>"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",
   		"merchant_id"=>"A3VX72MEBB21JI",
   		"marketplace_id"=>US_MKT
		)
		
		mws_fd = Amazon::MWS::Base.new(
   		"access_key"=>"AKIAIUCCPIMBYXZOZMXQ",
   		"secret_access_key"=>"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",
   		"merchant_id"=>"A39CG4I2IXB4I2",
   		"marketplace_id"=>US_MKT
		)		

		 
		response_id = Order.get_amz_orders(mws_hdo, Time.current().yesterday)
		if !response_id.nil?
			response = Response.find(response_id)	
			flash[:notice] = "Error - #{response.error_code}: #{response.error_message}"
		end
		@my_orders = Order.all

	end	
end