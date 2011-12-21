class VariantImage < ActiveRecord::Base
	belongs_to :variant
	has_attached_file :image, PAPERCLIP_STORAGE_OPTIONS
	before_validation :add_width
	
	validates_uniqueness_of :unique_image_file_name, :scope => [:variant_id]
	validates_numericality_of :image_width

	# if a width has been specified, do nothing - otherwise get width for the image
	def add_width
		if !self.image_width.is_a?(Numeric) 
  		self.image_width = Paperclip::Geometry.from_file(self.image.to_file(:original)).width
  	end
	end
	
end
