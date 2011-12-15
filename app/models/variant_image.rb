class VariantImage < ActiveRecord::Base
	belongs_to :variant
	has_attached_file :image, :dependent => :destroy
end
