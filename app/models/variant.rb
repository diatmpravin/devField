class Variant < ActiveRecord::Base
	belongs_to :product
	#delegate_belongs_to :product, :name, :description, :available_on, :meta_description, :meta_keywords
	has_many :variant_images, :dependent => :destroy
	has_many :mws_order_items, :class_name => 'MwsOrderItem', :foreign_key => 'clean_sku', :primary_key => 'sku'
	
	validates_uniqueness_of :sku
	
	def get_style
		color1 = self.color1.nil? ? '' : self.color1.strip
		color2 = self.color2.nil? ? '' : self.color2.strip
		return (color1 + ' ' + color2).strip
	end
	
	def get_attributes_for_shopify
		return { 	:price => self.cost_price * (1+self.product.brand.default_markup), 
							:requires_shipping => true,
							:title => "#{self.product.name} (#{get_style})",
							:inventory_quantity => 1,
							:inventory_policy => "deny",
							:taxable => true,
							:grams => self.weight,
							:sku => self.sku,
							:option1 => "#{get_style}",
							:fulfillment_service => "manual" }
	end
	
	def get_image_for_shopify(i)
		if self.variant_images.count >= 1
			desired_width = 320
			if i==0
				desired_width = 400
			end
			vi = self.variant_images.where(:image_width => desired_width).limit(1)
			if !vi.nil? && vi.count>0
				return { :src => vi.first.image.url }
			else
				return { :src => self.variant_images.first.image.url }
			end
		else
			return nil
		end
	end
	
end
