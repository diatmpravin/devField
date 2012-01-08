require 'test_helper'

class ProductsStoresTest < ActiveSupport::TestCase
	
	test "add_to_store and remove_from_store should work" do
		p = Factory(:product)
		s = Factory(:store, :store_type => 'Shopify')
		assert_equal 0, s.products.count
		assert_equal 0, p.stores.count
		ps = ProductsStore.create(:product => p, :store => s)
		assert_instance_of ProductsStore, ps
		assert_equal 1, s.reload.products.count
		assert_equal 1, p.reload.stores.count
		assert_equal p, s.products.first
		assert_equal s, p.stores.first
		
		ps.destroy
		assert_equal 0, s.reload.products.count
		assert_equal 0, p.reload.stores.count
		
		#TODO some test that actually checks the remote site? 
	end

end
