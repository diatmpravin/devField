require 'test_helper'

class ProductTest < ActiveSupport::TestCase
	test "product stores relation should work" do
		s = FactoryGirl.create(:store)
		s2 = FactoryGirl.create(:store, :name => 'LuxuryVision')
		p = FactoryGirl.create(:product)
		ProductsStore.find_or_create_by_product_id_and_store_id(p.id, s.id)
		assert_equal 1, p.stores.count
		ProductsStore.find_or_create_by_product_id_and_store_id(p.id, s2.id)
		assert_equal 2, p.stores.count
		assert_equal s, p.stores[0]
		assert_equal s2, p.stores[1]
	end
	
	test "variants relation should work" do
		p = FactoryGirl.create(:product)
		assert_equal 0, p.variants.count
		v = FactoryGirl.create(:variant, :product => p)
		assert_equal 1, p.variants.count
		v2 = FactoryGirl.create(:variant, :product => p)
		assert_equal 2, p.variants.count
	end
	
	test "brand should be valid" do
		p = FactoryGirl.build(:product)
		assert p.valid?
		p.brand_id = nil
		assert p.invalid?
	end
	
	test "base_sku should be unique" do
		b = FactoryGirl.create(:brand)
		p = FactoryGirl.create(:product, :base_sku => 'NotUnique', :brand => b)
		p2 = FactoryGirl.build(:product, :base_sku => 'NotUnique', :brand => b)
		assert p2.invalid?
		assert p2.errors[:base_sku].any?
	end
			
	test "search should work" do
		p = FactoryGirl.create(:product, :name => 'Carmichel')
		v = FactoryGirl.create(:variant, :product => p, :upc => 'Ray-Bans')
		v2 = FactoryGirl.create(:variant, :product => p, :upc => 'Ray-Bans')
		p2 = FactoryGirl.create(:product, :name => 'Carmichel')
		v3 = FactoryGirl.create(:variant, :product => p2, :sku => 'Ray-ABC345')
		p3 = FactoryGirl.create(:product, :name => 'Nonsense')
		
		# search term matching a single order via two items
		arr = Product.search('Ray-Ban')
		assert_instance_of ActiveRecord::Relation, arr
		assert_equal 1, arr.length
		assert_equal p, arr[0]
		
		# search term partially matching 2 orders
		arr = Product.search('Ray-')
		assert_instance_of ActiveRecord::Relation, arr
		assert_equal 2, arr.length
		assert_equal [p, p2], arr

		arr = Product.search('Carmichel')
		assert_equal 2, arr.length
		
		# search term matching back half of string only matching 1 order
		arr = Product.search('ABC')
		assert_instance_of ActiveRecord::Relation, arr
		assert_equal 1, arr.size
		assert_equal p2, arr[0]
		
		# search term should not match any orders
		arr = Product.search('xxx')
		assert_instance_of ActiveRecord::Relation, arr
		assert arr.empty?
	
	end
				
end
