class Variant < ActiveRecord::Base
	belongs_to :product
	#delegate_belongs_to :product, :name, :description, :available_on, :meta_description, :meta_keywords
	has_many :variant_images, :dependent => :destroy
	has_many :mws_order_items, :primary_key => "sku", :foreign_key => "sku", 
	
	validates_uniqueness_of :sku
end
