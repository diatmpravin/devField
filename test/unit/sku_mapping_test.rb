require 'test_helper'

class SkuMappingTest < ActiveSupport::TestCase

	test "get_catalog_match should work" do
		p = FactoryGirl.create(:product)
		sm = FactoryGirl.create(:sku_mapping, :sku=>p.base_sku, :granularity=>'product', :foreign_id=>p.id)
		assert_equal p, sm.get_catalog_match
		assert_equal p, SkuMapping.get_catalog_match(p.base_sku)
		assert_nil SkuMapping.get_catalog_match('unmatched_sku')
	end

end
