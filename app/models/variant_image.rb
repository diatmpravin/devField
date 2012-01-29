require 'open-uri'
#require 'openssl'
#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class VariantImage < ActiveRecord::Base
	belongs_to :variant
	has_attached_file :image, PAPERCLIP_STORAGE_OPTIONS.merge({:styles => { :thumb => "x30" }})
	before_validation :prep_paperclip
	validates_uniqueness_of :unique_image_file_name, :scope => [:variant_id]
	validates_numericality_of :image_width

	def self.reprocess_all
		VariantImage.all.each do |vi|
			vi.image.reprocess! if vi.image
		end
	end

	def prep_paperclip
		if self.image_file_name.nil? && !self.unique_image_file_name.nil?
			download_remote_image
		end
		if !self.image_width.is_a?(Numeric) || !self.image_file_name.nil?
			set_image_width
		end
	end

  def download_remote_image    
    io = open(URI.parse(self.unique_image_file_name))
    def io.original_filename; base_uri.path.split('/').last; end
    self.image = io.original_filename.blank? ? nil : io
  rescue # catch url errors with validations instead of exceptions (Errno::ENOENT, OpenURI::HTTPError, etc...) 
  end

	# if a width has been specified, do nothing - otherwise get width for the image
	def set_image_width 
		if !self.image.to_file(:original).nil?
			self.image_width = Paperclip::Geometry.from_file(self.image.to_file(:original)).width
		end
	end
	
end
