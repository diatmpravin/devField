require 'test_helper'

class StoreTest < ActiveSupport::TestCase
    
  test "store_type should be valid" do
		s = FactoryGirl.create(:store)
		
		# valid name, invalid store type
		assert_difference('Store.count',0) do
			s.name = 'Unique store name'
			s.store_type = 'Shopify2'
			Store.create(s.attributes)
		end
  end
  
  test "mws store should have valid connection and page size properties" do
  	s = FactoryGirl.create(:store, :store_type=>'MWS')		
		s.name = 'Unique store name'
		
		# bad order results per page and max order pages
		s2 = Store.new(s.attributes)
		s2.order_results_per_page = nil
		s2.max_order_pages = nil
		assert s2.invalid?
		assert s2.errors['order_results_per_page'].any?
		assert s2.errors['max_order_pages'].any?		
		
		# Verify and Queue flags should default to safe test settings
		assert_equal 'True', s.verify_flag
		assert_equal 'False', s.queue_flag		
	end
  
  test "store name should be unique" do 	
		s = FactoryGirl.create(:store)
			
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
		s = FactoryGirl.create(:store)
		s.store_type = 'Shopify'
		assert s.valid?
		s.authenticated_url = nil
		assert s.invalid?, "Shopify store with nil authenticated_url is valid"
	end
	
	test "get_orders_missing_items should work" do
		assert_difference('MwsOrder.count',1) do
			o = FactoryGirl.create(:mws_order)
			s = o.store
			assert_equal 1, s.get_orders_missing_items.count
		end

		assert_difference('MwsOrder.count',2) do
			o = FactoryGirl.create(:mws_order)
			s = o.store
			o2 = FactoryGirl.create(:mws_order, :store => s)
			assert_equal s, o2.store 
			assert_equal 2, s.get_orders_missing_items.count
		end
	end

	test "init_mws_connection should work" do
  	s = FactoryGirl.create(:store, :store_type=>'MWS')
		assert_instance_of Amazon::MWS::Base, s.mws_connection
		#s.mws_connection.stubs(:get).returns(xml_for('error',401))
	end
		
end
