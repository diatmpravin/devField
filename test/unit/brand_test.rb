require 'test_helper'

class BrandTest < ActiveSupport::TestCase

	test "name should be unique" do
		b = Factory(:brand)
		assert_difference('Brand.count',0) do
			Brand.create(b.attributes)
		end	

		b.name = 'unique brand name'
		assert_difference('Brand.count',1) do
			Brand.create(b.attributes)
		end
	end
   
	test "default_markup should be a number greater than zero" do   	
		b = Factory(:brand)
		b.default_markup = "NAN"
		assert b.invalid?
		assert b.errors[:default_markup].any?
		b.default_markup = 0.75
		assert b.valid?
		b.default_markup = 3
		assert b.valid?
		b.default_markup = -0.5
		assert b.invalid?
		assert b.errors[:default_markup].any?
		b.default_markup = 0
		assert b.invalid?
		assert b.errors[:default_markup].any?
	end
	
	#test "process_from_vendor should work" do
		#what to test here?
	#end

	#test "has zero or more products" do
		#what to test here?
	#end

	test "has a vendor" do
		b = Factory(:brand)
		assert_instance_of Vendor, b.vendor, 'Brand does not have a valid parent vendor'
	end
   
end
