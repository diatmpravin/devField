class MwsOrderItem < ActiveRecord::Base
	belongs_to :mws_order
	validates_uniqueness_of :amazon_order_item_id
	validates_presence_of :mws_order_id

	def clean_sku
		return self.seller_sku.gsub(/-AZ.*$/,'')
	end
	
	def product_price_per_unit
		return ((self.item_price + self.item_tax - self.promotion_discount) / self.quantity_ordered)
	end
	
	def sh_total
		return (self.shipping_price + self.shipping_tax - self.shipping_discount + self.gift_price + self.gift_tax)
	end

	def get_omx_info
		omx_connection = RubyOmx::Base.new(
			"http_biz_id" => 'KbmCrvnukGKUosDSTVhWbhrYBlggjNYxGqsujuglguAJhXeKBYDdpwyiRcywvmiUrpHilblPqKgiPAOIfxOfvFOmZLUiNuIfeDrKJxvjeeblkhphUhgPixbvaCJADgIfaDjHWFHXePIFchOjQciNRdrephpJFEfGoUaSFAOcjHmhfgZidlmUsCBdXgmmxIBKhgRjxjJaTcrnCgSkghRWvRwjZgVeVvhHqALceQpdJLphwDlfFXgIHYjCGjCiwZW',
			"udi_auth_token" => '7509fd470db4004809083c0048ef983102d6325b27730421704c1b0899109ab51de58e4dfd80acff062f8042360b5ae01ed4851f50a5d5fe38a10e81c0471a089f20799ddf11c81cc541a10a014fe04e190aee6049efdf97699096bd79db0a9fd04ca90b2a90f63925c223d236fbe97b047c104b900b7e1010fbb39453e0920'
		)
		response = omx_connection.get_item_info(:raw_xml => 0, :item_code => self.clean_sku)
		return response
		#response = omx_connection.get_custom_item_info(:raw_xml => 1, :item_code => self.clean_sku)
		#puts response.body.to_s
		
		#puts "item_code:#{response.item_code} active:#{response.active} product_name:#{response.product_name} price_type:#{response.price_type} price_amount:#{response.price_amount} #{response.price_quantity} incomplete:#{response.incomplete} inv:#{response.available_inventory} sub_item_count:#{response.sub_item_count} #{response.last_updated_date} #{response.weight}"
	end	
	
end