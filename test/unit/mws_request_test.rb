require 'test_helper'

class MwsRequestTest < ActiveSupport::TestCase

	test 'should have many mws_orders' do
		s = Factory(:store, :name => 'FieldDay')
		req = Factory(:mws_request, :store => s)
		assert_equal 0, req.mws_orders.count
		
		resp = Factory(:mws_response, :mws_request => req)
		o = Factory(:mws_order, :mws_response => resp, :store => s)
		
		assert_equal 1, req.mws_orders.count
		
		o2 = Factory(:mws_order, :mws_response => resp, :store => s)
		assert_equal 2, req.reload.mws_orders.count		
	end
	
	test 'get_orders_missing_items should work' do
		s = Factory(:store, :name => 'FieldDay')
		req = Factory(:mws_request, :store => s)
		resp = Factory(:mws_response, :mws_request => req)
		o = Factory(:mws_order, :mws_response => resp, :store => s)
		
		# should return orders with zero items ordered
		arr = req.get_orders_missing_items
		assert_equal o, arr[0]
		assert_equal 1, arr.count
		
		# as well as orders with >0 items ordered and 0 items loaded
		o.number_of_items_unshipped = 1
		o.save
		assert_equal 1, req.reload.get_orders_missing_items.count
		
		# incremental order should increment orders missing items count
		o2 = Factory(:mws_order, :mws_response => resp, :store => s, :number_of_items_unshipped => 2)
		arr = req.reload.get_orders_missing_items
		assert_equal 2, arr.count
		
		# loading an item should increment orders missing items count
		i = Factory(:mws_order_item, :mws_order => o, :quantity_ordered => 1)
		arr = req.reload.get_orders_missing_items
		assert_equal o2, arr[0]
		assert_equal 1, arr.count

		# loading another item should not change anything, as order is still short by 1 item
		i2 = Factory(:mws_order_item, :mws_order => o2, :quantity_ordered => 1)
		arr = req.reload.get_orders_missing_items
		assert_equal o2, arr[0]
		assert_equal 1, arr.count

		# loading another item should solve the problem, bringing orders missing to zero
		i3 = Factory(:mws_order_item, :mws_order => o2, :quantity_ordered => 1)
		req.reload
		arr = req.get_orders_missing_items
		assert_equal 0, arr.count
	end
	
	test 'get_responses_with_errors and sub_requests should work' do
		s = Factory(:store, :name => 'FieldDay')
		req = Factory(:mws_request, :store => s)
		resp = Factory(:mws_response, :mws_request => req)
		req_a = Factory(:mws_request, :mws_request_id => req.id)
		resp_a = Factory(:mws_response, :mws_request => req_a, :error_message => 'Error message')
		req_b = Factory(:mws_request, :mws_request_id => req.id)
		resp_b = Factory(:mws_response, :mws_request => req_b, :error_message => 'Error message')
		arr = req.reload.get_responses_with_errors
		assert_equal 2, arr.count
		assert_instance_of MwsResponse, arr[0]
		assert_equal 2, req.sub_requests.count
		
		o = Factory(:mws_order, :store => s, :mws_response => resp)
		assert_equal 1, req.reload.mws_orders.count
		assert_equal 1, resp.reload.mws_orders.count
		assert_equal "ERROR: #{arr.count} errors, 1 response pages, 1 orders, 1 without items", req.get_request_summary_string
	end
			
	# process_response
end
