class Brand < ActiveRecord::Base
	belongs_to :vendor
	has_many :products
	has_attached_file :icon
	
end
