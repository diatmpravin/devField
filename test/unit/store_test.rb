require 'test_helper'

class StoreTest < ActiveSupport::TestCase
  
  test "store_type should be valid" do
		s = Factory(:store)
		
		# valid name, invalid store type
		assert_difference('Store.count',0) do
			s.name = 'Unique store name'
			s.store_type = 'Shopify2'
			Store.create(s.attributes)
		end
  end
  
  test "mws store should have valid connection and page size properties" do
  	s = Factory.create(:store, :name => 'FieldDay')
  	
  	# initialize connection
  	assert_equal 'FieldDay', s.name
  	assert_equal 'MWS', s.store_type
		assert_instance_of Amazon::MWS::Base, s.mws_connection
		
		s.name = 'Unique store name'
		
		assert_difference('Store.count',0) do
			s.order_results_per_page = nil
			Store.create(s.attributes)
		end
		
		assert_difference('Store.count',0) do
			s.max_order_pages = nil
			Store.create(s.attributes)
		end
		
		# Verify and Queue flags should default to safe test settings
		assert_equal 'True', s.verify_flag
		assert_equal 'False', s.queue_flag		
		
	end
  
  test "store name should be unique" do
  	
		s = Factory(:store)
			
		# duplicate name	
		assert_difference('Store.count',0) do
			Store.create(s.attributes)
		end
		
		# duplicate name but in new, valid store type context
		assert_difference('Store.count',1) do
			s.store_type = 'Shopify'
			Store.create(s.attributes)
		end
		
		# new and unique name
		assert_difference('Store.count',1) do
			s.name = "unique store name"
			Store.create(s.attributes)
		end
		
	end

	# shopify stores should have an authenticated URL
	test "shopify stores should have an authenticated URL" do
		s = Factory(:store)
		s.store_type = 'Shopify'
		assert s.valid?
		s.authenticated_url = nil
		assert s.invalid?, "Shopify store with nil authenticated_url is valid"
	end
	
	test "get_orders_missing_items should work" do
		assert_difference('MwsOrder.count',1) do
			o = Factory(:mws_order)
			s = o.store
			assert_equal 1, s.get_orders_missing_items.count
		end

		assert_difference('MwsOrder.count',2) do
			o = Factory(:mws_order)
			s = o.store
			o2 = Factory(:mws_order, :store => s)
			assert_equal s, o2.store 
			assert_equal 2, s.get_orders_missing_items.count
		end
	end
		
end
