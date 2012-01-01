require 'test_helper'

class VendorTest < ActiveSupport::TestCase
 
	test "name should be unique" do
		v = Factory(:vendor)
		
		assert_difference('Vendor.count',0) do
			Vendor.create(v.attributes)
		end
		
		v.name = "unique vendor name"
		assert_difference('Vendor.count',1) do
			Vendor.create(v.attributes)
		end
	end

	test "products relation should work and clear_products should remove all products" do
		v = Factory(:vendor)
		b = Factory(:brand, :vendor => v)
		p = Factory(:product, :brand => b)
		p2 = Factory(:product, :brand => b)
		assert_equal 2, v.products.count
		
		assert_difference('Product.count',-2) do
			v.clear_products
		end
	end

	test "login should assign a mechanize object" do
		v = Factory(:vendor)
		v.login
		assert_not_nil v.agent
		assert_instance_of Mechanize, v.agent
		# assert that the URL equals the brand nexus URL?
	end

	#process_brands
	#process_brand(b)
	#process_items_page(brand)
	#process_item(brand, link)
	#process_item_variants(product, page)
	#process_variant(variant, row)
	#process_item_variant_images(product, page)
	#process_item_variant_image(variant, img, width, chip_group)
	

end
