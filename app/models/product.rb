class Product < ActiveRecord::Base
	belongs_to :brand
	has_many :variants, :dependent => :destroy

  has_one :master, :class_name => 'Variant',
      		:conditions => ["variants.is_master = ? AND variants.deleted_at IS NULL", true]	
	
	#delegate_belongs_to :master, :sku, :price, :weight, :height, :width, :depth, :cost_price, :is_master

  has_many :variants,
      :class_name => 'Variant',
      :conditions => ["variants.is_master = ? AND variants.deleted_at IS NULL", false],
      :dependent => :destroy, #added this
      :order => "variants.position ASC"

  has_many :variants_including_master,
      :class_name => 'Variant',
      :conditions => ["variants.deleted_at IS NULL"],
      :dependent => :destroy

  has_many :variants_with_only_master,
      :class_name => 'Variant',
      :conditions => ["variants.deleted_at IS NULL AND variants.is_master = ?", true],
      :dependent => :destroy
	
	validates :name, :presence => true
	validates_uniqueness_of :base_sku, :scope => [:brand_id]

	def append_to_shopify
		ShopifyAPI::Base.site = "https://04b6a9a830b55a658e6ccafa26f8e4ac:ba4b5399210d11843a6ae70592fbd4e4@fieldday.myshopify.com/admin"
		images_arr = Array.new
		variants_arr = Array.new
		variants = self.variants
		i = 0
		variants.each do |v|
			variants_arr << {	:price => "#{v.cost_price * 2}", 
												:requires_shipping => true,
												:title => "#{self.name} #{v.color1}",
												:inventory_quantity => 1,
												:inventory_policy => "deny",
												:taxable => true,
												:grams => v.weight,
												:sku => v.sku,
												:option1 => "#{v.color1} (#{v.color2})",
												:fulfillment_service => "manual" }
			if i==0 || v.variant_images.count == 1
				images_arr << { :src => v.variant_images.first.image.url }
			else
				images_arr << { :src => v.variant_images.first.image.url } #TODO logic to take the closeup image where available
			end
			i += 1
		end
		
		brand = self.brand.name
		product = ShopifyAPI::Product.create({
				:product_type => self.category,
				:title => self.name,
				:body_html => self.description,
				:images => images_arr,
				:variants => variants_arr,
				:published => true,
				:tags => "#{brand} #{self.category}, #{brand} #{self.name}",
				:vendor => brand,
				:options => [ {:name => 'Color'}] })
	end
	
end
