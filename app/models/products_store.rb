class ProductsStore < ActiveRecord::Base
	belongs_to :store
	belongs_to :product
	validates_uniqueness_of :product_id, :handle, :foreign_id, :scope => [:store_id]
	validates_associated :store, :product
	
	before_create :add_to_store
	before_destroy :remove_from_store
	
	def add_to_store
		if self.store.store_type == 'Shopify'
			append_to_shopify
		elsif self.store.store_type == 'MWS'
			append_to_mws
		end
	end

	def remove_from_store					
		if self.store.store_type == 'Shopify'
			remove_from_shopify
		elsif self.store.store_type == 'MWS'
			remove_from_mws
		end
	end

	private
	def append_to_shopify
		if self.store.authenticated_url.nil?
			return nil
		end
		ShopifyAPI::Base.site = self.store.authenticated_url
				
		variants_arr = Array.new
		images_arr = Array.new 
		i = 0
		self.product.variants_including_master.each do |v|
			variants_arr << v.attributes_for_shopify
			images_arr << v.image_for_shopify(i)
			i += 1
		end
		
		to_publish = true
		if images_arr.count==0
			to_publish = false
		end

		brand = self.product.brand		
		shopify_product = ShopifyAPI::Product.create({
				:product_type => self.product.category,
				:title => self.product.name,
				:body_html => self.product.description,
				:images => images_arr,
				:variants => variants_arr,
				:published => to_publish,
				:tags => "#{brand} #{self.product.category}, #{brand.name} #{self.product.name}",
				:vendor => brand.name,
				:options => [ {:name => 'Color'}] }) #TODO make color more general, option values and stuff
		self.handle = shopify_product.handle
		self.foreign_id = shopify_product.id	
	end
	
	def remove_from_shopify
		shopify_product = ShopifyAPI::Product.find(self.foreign_id)
		shopify_product.destroy
		#TODO is destroy the right way to interact with the shopify API here?
	end
	
	def append_to_mws
		# TODO code for append to mws
	end
	
	def remove_from_mws
		#TODO code for remove from mws
	end
	
end
