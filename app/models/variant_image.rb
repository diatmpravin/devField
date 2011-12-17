class VariantImage < ActiveRecord::Base
	belongs_to :variant
	has_attached_file :image, PAPERCLIP_STORAGE_OPTIONS
	validates_uniqueness_of :unique_image_file_name, :scope => [:variant_id]
	validates_numericality_of :image_width, { :only_integer => true }
	
	def self.add_all_widths
		variant_images = VariantImage.all
		variant_images.each do |vi|
			vi.image_width = vi.unique_image_file_name.split(/.jpg/)[0][-3,3]
			vi.save!
		end 
	end
	
end
