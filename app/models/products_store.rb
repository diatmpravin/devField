require 'amazon/mws'

class ProductsStore < ActiveRecord::Base
	belongs_to :store
	belongs_to :product
	validates_uniqueness_of :product_id, :handle, :foreign_id, :scope => [:store_id], :allow_nil=>true
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

	#private
	def append_to_shopify
		if self.store.authenticated_url.nil?
			return nil
		end
		ShopifyAPI::Base.site = self.store.authenticated_url
				
		variants_arr = Array.new
		images_arr = Array.new 
		i = 0
		self.product.variants.each do |v|
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

	#MESSAGE_TYPES = [
  #      "FulfillmentCenter",
  #      "Inventory",
  #      "OrderAcknowledgement",
  #      "OrderAdjustment",
  #      "OrderFulfillment",
  #      "OrderReport",
  #      "Override",
  #      "Price",
  #      "ProcessingReport",
  #      "Product",
  #      "ProductImage",
  #      "Relationship",
  #      "SettlementReport"
  #   ]

  #   FEED_TYPES = {
  #      :product_data              => '_POST_PRODUCT_DATA_',
  #      :product_relationship_data => '_POST_PRODUCT_RELATIONSHIP_DATA_',
  #      :item_data                 => '_POST_ITEM_DATA_',
  #      :product_overrides         => '_POST_PRODUCT_OVERRIDES_DATA_',
  #      :product_image_data        => '_POST_PRODUCT_IMAGE_DATA_',
  #      :product_pricing           => '_POST_PRODUCT_PRICING_DATA_',
  #      :inventory_availability    => '_POST_INVENTORY_AVAILABILITY_DATA_',
  #      :order_acknowledgement     => '_POST_ORDER_ACKNOWLEDGEMENT_DATA_',
  #      :order_fulfillment         => '_POST_ORDER_FULFILLMENT_DATA_',
  #      :payment_adjustment        => '_POST_PAYMENT_ADJUSTMENT_DATA_',

	#sku	product-id	product-id-type	product-name	brand	bullet-point1	bullet-point2	bullet-point3	bullet-point4	bullet-point5	product-description	clothing-type	size	size-modifier	color	color-map	material-fabric1	material-fabric2	material-fabric3	department1	department2	department3	department4	department5	style-keyword1	style-keyword2	style-keyword3	style-keyword4	style-keyword5	occasion-lifestyle1	occasion-lifestyle2	occasion-lifestyle3	occasion-lifestyle4	occasion-lifestyle5	search-terms1	search-terms2	search-terms3	search-terms4	search-terms5	size-map	waist-size-unit-of-measure	waist-size	inseam-length-unit-of-measure	inseam-length	sleeve-length-unit-of-measure	sleeve-length	neck-size-unit-of-measure	neck-size	chest-size-unit-of-measure	chest-size	cup-size	shoe-width	parent-child	parent-sku	relationship-type	variation-theme	main-image-url	swatch-image-url	other-image-url1	other-image-url2	other-image-url3	other-image-url4	other-image-url5	other-image-url6	other-image-url7	other-image-url8	shipping-weight-unit-measure	shipping-weight	product-tax-code	launch-date	release-date	msrp	item-price	sale-price	currency	fulfillment-center-id	sale-from-date	sale-through-date	quantity	leadtime-to-ship	restock-date	max-aggregate-ship-quantity	is-gift-message-available	is-gift-wrap-available	is-discontinued-by-manufacturer	registered-parameter	update-delete

	
	def append_to_mws
		product = self.product
		message_hash = { 'sku'=>product.base_sku, 'product-name'=>product.name }
		response = self.store.mws_connection.submit_feed(:product_data,'Product',message_hash)
	end
	
	def remove_from_mws
		#TODO code for remove from mws
	end
	
end
