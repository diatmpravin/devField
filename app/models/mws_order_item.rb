class MwsOrderItem < ActiveRecord::Base
	belongs_to :mws_order
	belongs_to :mws_response
	belongs_to :variant, :foreign_key => "clean_sku"
	before_save :save_clean_sku
	
	validates_uniqueness_of :amazon_order_item_id
	validates_presence_of :mws_order_id
	# TODO validate presence, numericality, and positiveness of price
	
	def set_shipped
		self.quantity_shipped = self.quantity_ordered
		self.save!
	end

	def is_gift?
		if !self.gift_message_text.nil? || !self.gift_wrap_level.nil? 
			return 1
		else
			return 0
		end
	end
	
	def product_price_per_unit
		if self.quantity_ordered.nil? || self.quantity_ordered == 0
			return 0
		elsif self.item_price.nil?
			return 0
		else
			return ((self.item_price + self.item_tax - self.promotion_discount) / self.quantity_ordered)
		end
	end

	def get_item_price
		total = 0
		total += self.item_price ? self.item_price : 0 
		total += self.item_tax ? self.item_tax : 0
		total -= self.promotion_discount ? self.promotion_discount : 0
		return total
	end

	def get_ship_price
		total = 0
		total += self.shipping_price ? self.shipping_price : 0
		total += self.shipping_tax ? self.shipping_tax : 0
		total -= self.shipping_discount ? self.shipping_discount : 0
		return total
	end

	def get_gift_price
		total = 0
		total += self.gift_price ? self.gift_price : 0
		total += self.gift_tax ? self.gift_tax : 0
		return total
	end
	
	def get_total_price
		total = self.get_item_price + self.get_ship_price + self.get_gift_price
		return total
	end
		
	
	def sh_total
		return (self.get_ship_price + self.get_gift_price)
		#return (self.shipping_price + self.shipping_tax - self.shipping_discount + self.gift_price + self.gift_tax)
	end

	def get_omx_info
		omx_connection = RubyOmx::Base.new(
			"http_biz_id" => 'KbmCrvnukGKUosDSTVhWbhrYBlggjNYxGqsujuglguAJhXeKBYDdpwyiRcywvmiUrpHilblPqKgiPAOIfxOfvFOmZLUiNuIfeDrKJxvjeeblkhphUhgPixbvaCJADgIfaDjHWFHXePIFchOjQciNRdrephpJFEfGoUaSFAOcjHmhfgZidlmUsCBdXgmmxIBKhgRjxjJaTcrnCgSkghRWvRwjZgVeVvhHqALceQpdJLphwDlfFXgIHYjCGjCiwZW',
			"udi_auth_token" => '7509fd470db4004809083c0048ef983102d6325b27730421704c1b0899109ab51de58e4dfd80acff062f8042360b5ae01ed4851f50a5d5fe38a10e81c0471a089f20799ddf11c81cc541a10a014fe04e190aee6049efdf97699096bd79db0a9fd04ca90b2a90f63925c223d236fbe97b047c104b900b7e1010fbb39453e0920'
		)
		response = omx_connection.get_item_info(:raw_xml => 0, :item_code => self.clean_sku)
		return response
	end	

	protected
	def save_clean_sku
		if !self.seller_sku.nil?
			self.clean_sku = self.seller_sku.gsub(/-AZ.*$/,'')
		end
	end
	
end