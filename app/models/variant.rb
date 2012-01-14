class Variant < ActiveRecord::Base
	belongs_to :product
	#delegate_belongs_to :product, :name, :description, :available_on, :meta_description, :meta_keywords
	has_many :variant_images, :dependent => :destroy
	has_many :mws_order_items, :class_name => 'MwsOrderItem', :foreign_key => 'clean_sku', :primary_key => 'sku'
	
	validates_uniqueness_of :sku
	#before_update :register_changes

	#def register_changes
		
	#end

	def get_clean_sku
		p = self.product
		b = p.brand.name
		if b == 'Vogue' 							#VO2648-1437-49
			return "#{p.base_sku}-#{self.color1_code}-#{self.size[0,2]}"
		elsif b == 'Polo'							#PH3042-900171
			return "#{p.base_sku}-#{self.color1_code}"
		elsif b == 'Ralph'						#RA4004-10313-59
			return "#{p.base_sku}-#{self.color1_code.gsub(/\//,'')}-#{self.size[0,2]}"
		elsif b == 'Dolce & Gabbana' 	#DD8039-502-73 vs. 0DD8089-501/8G-5916
			# tricky as there are two versions
			# 0DD1176-814-5217 > DD1176-675-52, DD2192-338 doesn't have size at all, DD3034-154413 same
			#return "#{p.base_sku}-#{v.color1_code}-#{v.size[0,2]}"
			return "#{p.base_sku}-#{self.color1_code.gsub(/\//,'-')}-#{self.size[0,2]}"			
		elsif b == 'Ray-Ban'
			return "#{p.base_sku}-#{self.color1_code}-#{self.size[0,2]}"							#RB3025-13
		else
			return self.sku
		end
	end

	# searches variants BUT returns an ActiveRecord association of the products associated with the matched variants
	def self.search(search)
		fields = [ 'sku', 'upc', 'size', 'color1', 'color2','color1_code','color2_code','availability', 'amazon_product_name', 'amazon_product_id', 'amazon_product_description' ] 
		select('product_id').where(MwsHelper::search_helper(fields, search)).group('product_id')
	end
	
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
