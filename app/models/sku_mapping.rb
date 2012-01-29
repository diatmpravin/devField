class SkuMapping < ActiveRecord::Base
	validates_uniqueness_of :sku
	validates_inclusion_of :granularity, :in => %w(product variant sub_variant), :message => 'Invalid granularity'
	validates_numericality_of :foreign_id, { :only_integer => true, :greater_than => 0 }

	def self.get_catalog_match(sku)
		sm = SkuMapping.find_by_sku(sku)
		if sm.nil?
			return nil
		else
			return sm.get_catalog_match
		end
	end

	def get_catalog_match
		if self.granularity == 'product'
			return Product.find(self.foreign_id)
		elsif self.granularity == 'variant'
			return Variant.find(self.foreign_id)
		elsif self.granularity == 'sub_variant'
			return SubVariant.find(self.foreign_id)
		else
			return nil
		end		
	end
end
