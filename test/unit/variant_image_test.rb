require 'test_helper'

class VariantImageTest < ActiveSupport::TestCase

	test "unique image file name should be unique" do
		vi = Factory(:variant_image)
		assert vi.valid?
		vi2 = Factory.build(:variant_image, :unique_image_file_name => vi.unique_image_file_name, :variant => vi.variant)
		assert vi2.invalid?
	end

	test "image_width should be present and numeric" do
		vi = Factory(:variant_image)
		assert_equal 400, vi.image_width
			
		#TODO test that an image is attached and auto assigned
		#TODO test that if there is an image_width provided, it's a number, and if not, it gets it from the file
	end

end
