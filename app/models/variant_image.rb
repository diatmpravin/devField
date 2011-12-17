class VariantImage < ActiveRecord::Base
	belongs_to :variant
	has_attached_file :image, PAPERCLIP_STORAGE_OPTIONS
	validates_uniqueness_of :unique_image_file_name, :scope => [:variant_id]
	validates_numericality_of :image_width
	before_validation :add_width
	
	def add_width
		dimensions = Paperclip::Geometry.from_file(self.image.to_file(:original))
  	self.image_width = dimensions.width 
	end
	
end
