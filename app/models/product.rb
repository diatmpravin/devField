class Product < ActiveRecord::Base
	belongs_to :brand
	has_many :products_stores
	has_many :stores, :through => :products_stores
	has_many :variants, :dependent => :destroy
	has_many :mws_order_items, :class_name => 'MwsOrderItem', :foreign_key => 'clean_sku', :primary_key => 'base_sku'	
	validates_associated :brand

  has_one :master, :class_name => 'Variant',
      		:conditions => ["variants.is_master = ? AND variants.deleted_at IS NULL", true]	
	
	#delegate_belongs_to :master, :sku, :price, :weight, :height, :width, :depth, :cost_price, :is_master

  has_many :variants_excluding_master,
      :class_name => 'Variant',
      :conditions => ["variants.is_master = ? AND variants.deleted_at IS NULL", false],
      :dependent => :destroy, #added this
      :order => "variants.position ASC"

  has_many :variants,
      :class_name => 'Variant',
      :conditions => ["variants.deleted_at IS NULL"],
      :dependent => :destroy,
      :order => "variants.position ASC, variants.id ASC"

  has_many :variants_with_only_master,
      :class_name => 'Variant',
      :conditions => ["variants.deleted_at IS NULL AND variants.is_master = ?", true],
      :dependent => :destroy
	
	validates :name, :presence => true
	validates_presence_of :brand_id
	validates_uniqueness_of :base_sku, :scope => [:brand_id]

	def self.search(search)
		# get sub_matches from order_items
		o1 = Variant.search(search).collect { |v| v.product_id }
		
		# get direct matches at order level
		# TODO searching a brand won't work here
		fields = [ 'name', 'description', 'meta_description', 'meta_keywords', 'base_sku', 'category' ]
		bind_vars = MwsHelper::search_helper(fields, search)
		o2 = select('id').where(bind_vars).collect { |p| p.id }
			
		# combine the two arrays of IDs and remove duplicates, and return all relevant records
		where(:id => o1 | o2)
	end

	#TODO delete this after running once on legacy products
	def self.set_default_masters
		Product.all.each do |p|
			p.set_default_master
		end
	end

	# If product does not have a master variant, then set the first variant as master
	def set_default_master	
		variants = self.reload.variants
		master = self.reload.master
		if variants.count >= 1 && master.nil?
			variants[0].is_master = true
			variants[0].save
		end
	end
	
end
