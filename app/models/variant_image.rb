class VariantImage < ActiveRecord::Base
	belongs_to :variant
	has_attached_file :image, PAPERCLIP_STORAGE_OPTIONS
	validates_uniqueness_of :unique_image_file_name, :scope => [:variant_id]
end
