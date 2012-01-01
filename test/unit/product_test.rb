require 'test_helper'

class ProductTest < ActiveSupport::TestCase
	test "product stores relation should work" do
		s = Factory(:store)
		s2 = Factory(:store, :name => 'LuxuryVision')
		p = Factory(:product)
		ProductsStore.find_or_create_by_product_id_and_store_id(p.id, s.id)
		assert_equal 1, p.stores.count
		ProductsStore.find_or_create_by_product_id_and_store_id(p.id, s2.id)
		assert_equal 2, p.stores.count
		assert_equal s, p.stores[0]
		assert_equal s2, p.stores[1]
	end
	
	test "variants relation should work" do
		p = Factory(:product)
		assert_equal 0, p.variants_including_master.count
		v = Factory(:variant, :product => p)
		assert_equal 1, p.variants_including_master.count
		v2 = Factory(:variant, :product => p)
		assert_equal 2, p.variants_including_master.count
	end
	
	test "brand should be valid" do
		p = Factory.build(:product)
		assert p.valid?
		p.brand_id = nil
		assert p.invalid?
	end
	
	test "base_sku should be unique" do
		b = Factory(:brand)
		p = Factory(:product, :base_sku => 'NotUnique', :brand => b)
		p2 = Factory.build(:product, :base_sku => 'NotUnique', :brand => b)
		assert p2.invalid?
		assert p2.errors[:base_sku].any?
	end
	
	test "add_to_store should work" do
		p = Factory(:product)
		s = Factory(:store)
		assert_equal 0, s.products.count
		assert_equal 0, p.stores.count
		ps = p.add_to_store(s)
		assert_instance_of ProductsStore, ps
		assert_equal 1, s.reload.products.count
		assert_equal 1, p.reload.stores.count
		assert_equal p, s.products.first
		assert_equal s, p.stores.first
	end
	
	test "append_to_shopify should work" do
		# how to stub the shopify response or just don't?
		# make it for real and then delete it?
		# TODO append to shopify test
	end
	
end
