require 'test_helper'

class MwsOrderTest < ActiveSupport::TestCase

	test "basic mws_order should be valid" do
		o = Factory(:mws_order)
		assert o.valid?
	end

	#validates_uniqueness_of :amazon_order_id
	test "amazon_order_id should be unique" do		
		assert_difference('MwsOrder.count',1) do
			o = Factory(:mws_order)
			MwsOrder.create(o.attributes)
		end
	end
	
	#validates_presence_of :mws_response_id
	test "mws_response_id is required" do
		o = Factory(:mws_order)
		o.mws_response_id = nil
		assert_difference('MwsOrder.count',0) do
			MwsOrder.create(o.attributes)
		end		
	end
	
	test "purchase date should not be nil" do
		o = Factory(:mws_order)
		o.purchase_date = nil
		assert o.invalid?
		o.purchase_date = Time.now
		assert o.valid?
	end
	
	test "get_item_quantity_loaded/ordered/missing should work" do
		o = Factory(:mws_order, :number_of_items_unshipped => 2, :number_of_items_shipped => 1)
		assert_equal 0, o.get_item_quantity_loaded
		assert_equal 3, o.get_item_quantity_ordered
		assert_equal 3, o.get_item_quantity_missing
		
		i = Factory(:mws_order_item, :mws_order => o, :quantity_shipped => 0, :quantity_ordered => 2)
		assert_equal 2, o.reload.get_item_quantity_loaded
		assert_equal 3, o.get_item_quantity_ordered
		assert_equal 1, o.get_item_quantity_missing
		
		i2 = Factory(:mws_order_item, :mws_order => o, :quantity_shipped => 1, :quantity_ordered => 1)
		assert_equal 3, o.reload.get_item_quantity_loaded
		assert_equal 3, o.get_item_quantity_ordered
		assert_equal 0, o.get_item_quantity_missing
	end
	
	test "get_sleep_time_per_order should work" do
		assert_equal 0, MwsOrder::get_sleep_time_per_order("text")
		assert_equal 0, MwsOrder::get_sleep_time_per_order(-1)
		assert_equal 0, MwsOrder::get_sleep_time_per_order(0)
		assert_equal 0, MwsOrder::get_sleep_time_per_order(1)
		assert_equal 0, MwsOrder::get_sleep_time_per_order(15)
		assert MwsOrder::get_sleep_time_per_order(16) > 0
		assert MwsOrder::get_sleep_time_per_order(50.5) > 0
		assert MwsOrder::get_sleep_time_per_order(10000) <= 6
	end
	
	test "order should have an associated MWS connection" do
		s = Factory(:store, :name => 'FieldDay')
		o = Factory(:mws_order, :store => s)
  	#o = MwsOrder.find(o.id)
  	s = o.reload.store
  	assert s.valid?
  	assert_equal 'FieldDay', s.name
  	assert_equal 'MWS', s.store_type		
		assert_instance_of Amazon::MWS::Base, s.mws_connection
	end
	
	test "reprocess_order should work" do
		s = Factory(:store, :name => 'FieldDay')
		o = Factory(:mws_order, :store => s)		
  	#o.reprocess_order
  	#TODO what to assert?  Just needs to not return error?
	end
	
	test "omx_responses relation and pushed_to_omx? should work" do
		s = Factory(:store, :name => 'FieldDay')
		o = Factory(:mws_order, :store => s)
		assert_equal 0, o.omx_responses.count
		assert_equal "Error", o.pushed_to_omx?
		
		i = Factory(:mws_order_item, :mws_order => o)
		req = Factory(:omx_request, :mws_order => o)
		resp = Factory(:omx_response, :omx_request => req)
		assert_equal 1, o.omx_responses.count
		assert_equal "Error", o.pushed_to_omx?
		
		o.append_to_omx
		assert_equal "No", o.reload.pushed_to_omx?

		resp.ordermotion_order_number = 'omx_order_number'
		resp.save
		assert_equal "Yes", o.reload.pushed_to_omx?
		
		resp.ordermotion_order_number = nil
		resp.error_data = 'The provided Order ID has already been used for the provided store (Amazon.com MFN HDO).'
		resp.save
		assert_equal "Dup", o.reload.pushed_to_omx?
		
		o.fulfillment_channel = 'AFN'
		o.save
		assert_equal "N/A", o.reload.pushed_to_omx?
	end
			
	test "omx_first_name should work" do
		o = Factory(:mws_order, :name => 'Bob C. Smith')
		assert_equal 'Bob C.', o.omx_first_name
		
		o.name = 'Smith'
		assert_equal '[Blank]', o.omx_first_name
		
		o.name = nil
		assert_equal '[Blank]', o.omx_first_name		
	end

	test "omx_last_name should work" do
		o = Factory(:mws_order, :name => 'Bob C. Smith')
		assert_equal 'Smith', o.omx_last_name
		
		o.name = 'Smith'
		assert_equal 'Smith', o.omx_last_name
		
		o.name = nil
		assert_equal '[Blank]', o.omx_last_name		
	end
	
	test "omx_shipping_method should work" do
		o = Factory(:mws_order)
		assert_equal 9, o.omx_shipping_method
		o.shipment_service_level_category = 'Expedited'
		assert_equal 11, o.omx_shipping_method
		o.shipment_service_level_category = 'NextDay'
		assert_equal 8, o.omx_shipping_method
		o.shipment_service_level_category = 'SecondDay'
		assert_equal 20, o.omx_shipping_method
		o.shipment_service_level_category = 'Blah Blah'
		assert_equal 9, o.omx_shipping_method
	end

	test "omx_state should work" do
		o = Factory(:mws_order)
		assert_equal nil, o.omx_state
		o.state_or_region = 'Not In The List'
		assert_equal 'Not In The List', o.omx_state
		o.state_or_region = 'Pennsylvania'
		assert_equal 'PA', o.omx_state
	end

	test "omx_gift_wrap etc should work" do
		o = Factory(:mws_order)
		assert_equal nil, o.omx_gift_wrap_level
		assert_equal nil, o.omx_gift_message
		assert_equal 'False', o.omx_gift_wrapping
		
		i = Factory(:mws_order_item, :mws_order => o)
		i2 = Factory(:mws_order_item, :mws_order => o)
		assert_equal 'False', o.reload.omx_gift_wrapping
		
		i2.gift_message_text = 'Happy Birthday'
		i2.save
		assert_equal 'True', o.reload.omx_gift_wrapping
		assert_equal 'Happy Birthday', o.omx_gift_message
		assert_equal nil, o.omx_gift_wrap_level
		
		i2.gift_message_text = nil
		i2.gift_wrap_level = 'Wrapped'
		i2.save

		assert_equal 'True', o.reload.omx_gift_wrapping
		assert_equal nil, o.omx_gift_message
		assert_equal 'Wrapped', o.omx_gift_wrap_level		
	end
				
	#TODO test append_to_omx
	#TODO test process_order
	#TODO test fetch_order_items
	#TODO test process_order_item
end
