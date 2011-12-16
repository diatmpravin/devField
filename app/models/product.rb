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
		images_arr = Array.new
		variants_arr = Array.new
		variants = self.variants
		variants.each do |v|
			variants_arr << {	:price => v.cost_price * 2, 
												:requires_shipping => true,
												:title => "#{self.name} #{v.color1}",
												:inventory_quantity => 1,
												:compare_at_price => nil,
												:inventory_policy => "deny",
												:inventory_management => nil,
												:taxable => true,
												:grams => 0,
												:sku => v.sku,
												:option1 => "#{v.color1} (#{v.color2})",
												:fulfillment_service => "manual",
												:option2 => nil,
												:option3 => nil }
			images_arr << v.variant_images.first.image.url
		end
		
		shop = ShopifyAPI::Shop.current
		
		product = ShopifyAPI::Product.create({
				:product_type => 'Sunglasses',
				:body_html => self.description,
				:title => self.name,
				:images => images_arr,
				:variants => variants_arr,
				:vendor => self.brand.name })
		
	end
	
end
