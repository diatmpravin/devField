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

	test "get_style should work" do
		v = Factory(:variant)
		assert_equal '', v.get_style
		v.color1 = 'Green '
		v.save
		assert_equal 'Green', v.reload.get_style
		v.color2 = ' Blue'
		v.save
		assert_equal 'Green Blue', v.reload.get_style
	end
	
	test "get_attributes_for_shopify should work" do
		p = Factory(:product, :name => 'Aviators')
		v = Factory(:variant, :product => p, :color1 => 'Green', :color2 => 'Blue', :cost_price => 1)
		a = v.get_attributes_for_shopify
		assert_equal 'Aviators (Green Blue)', a[:title]
		assert_equal 'Green Blue', a[:option1]
		assert_equal v.sku, a[:sku]
		assert_equal 2, a[:price] # default markup of 100%
	end
	
	test "get_image_for_shopify(i) should work" do
		v = Factory(:variant)
		assert_equal nil, v.get_image_for_shopify(nil)
		assert_equal nil, v.get_image_for_shopify(0)
		vi = Factory(:variant_image, :variant => v, :image_file_name => 'blah')
		temp1 = { :src => vi.image.url }
		assert_equal temp1, v.reload.get_image_for_shopify(0)
		vi2 = Factory(:variant_image, :variant => v, :image_file_name => 'blah2', :image_width => 320)
		temp2 = { :src => vi2.image.url }
		assert_equal temp1, v.reload.get_image_for_shopify(0)
		assert_equal temp2, v.reload.get_image_for_shopify(1)
	end
	
end
