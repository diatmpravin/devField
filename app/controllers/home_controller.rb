require 'mechanize'
require 'RubyOmx'

class HomeController < ApplicationController
  
  around_filter :shopify_session, :except => ['welcome']
  
  def welcome
    current_host = "#{request.host}#{':' + request.port.to_s if request.port != 80}"
    @callback_url = "http://#{current_host}/login/finalize"   
  end
  
  def index
    # get 3 products
    
    prod = Product.find(1)
    prod.append_to_shopify
    
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 3})

    # get latest 3 orders
    @orders   = ShopifyAPI::Order.find(:all, :params => {:limit => 3, :order => "created_at DESC" })
  
  end
	
end