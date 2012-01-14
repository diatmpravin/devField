class Brand < ActiveRecord::Base
	belongs_to :vendor
	has_many :products, :dependent => :destroy
	has_attached_file :icon, PAPERCLIP_STORAGE_OPTIONS.merge({:path => "/:class/:attachment/:id/:style/:filename"})
	
	validates_uniqueness_of :name
	validates_numericality_of :default_markup, { :only_integer => false, :greater_than => 0 }

	def revise_skus
		self.products.each do |p|
			p.base_sku = p.base_sku[1,p.base_sku.length-1]
			p.save
			p.variants.each do |v|
				v.sku = v.sku[1,v.sku.length-3]
				v.save
			end
		end
	end

	def process_from_vendor
		v = self.vendor
		v.login
		v.process_brand(self)
	end

	def add_to_store(store)
		self.products.each do |p|
			ProductsStore.create!(:product => p, :store => store)
		end
		return true
	end

	def remove_from_store(store)
		self.products.each do |p|
			ps = ProductsStore.find_by_product_id_and_store_id(p.id, store.id)
			if !ps.nil?
				ps.destroy
			end
		end
		return true
	end

end
