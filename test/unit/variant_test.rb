require 'test_helper'

class VariantTest < ActiveSupport::TestCase

	test "sku should be unique" do
		p = Factory(:product)
		v = Factory(:variant, :product => p)
		v2 = Factory(:variant, :product => p)
		assert v2.valid?
		v2.sku = v.sku
		assert v2.invalid?
	end
	
	test "mws_order_items association should work" do
		v = Factory(:variant, :sku => 'ABCDEFG')
		assert_equal 0, v.mws_order_items.count
		
		o = Factory(:mws_order)
		i = Factory(:mws_order_item, :mws_order => o, :seller_sku => 'ABCDEFG')
		assert_equal 1, v.mws_order_items.count
		i2 = Factory(:mws_order_item, :mws_order => o, :seller_sku => 'ABCDEFG')
		assert_equal 2, v.mws_order_items.count
	end
	
end
