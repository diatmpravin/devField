#require "amazonmws"

class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => 'welcome'
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"
  end
  
  def index
    # get 3 products
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 3})

    # get latest 3 orders
    @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })

		mws = AmazonMWS::Base.new(
   		"access_key"=>"AKIAIIPPIV2ZWUHDD5HA",
   		"secret_access_key"=>"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",
   		"merchant_id"=>"A3VX72MEBB21JI",
   		"marketplace_id"=>"ATVPDKIKX0DER"
		)

		response = mws.get_report_request_count

		@mws_message = ""
		if response.accessors.include?("code")
   		@mws_message = "Error: #{response.code}. Message: #{response.message}"
		else
   		@mws_message = "Number of requests is #{response.count}"
		end
   
  end
  
end