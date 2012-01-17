require 'test_helper'

class SubVariantTest < ActiveSupport::TestCase

	test "sku should be unique" do
		v = Factory(:variant)
		sv = Factory(:sub_variant, :variant => v)
		sv2 = Factory(:sub_variant, :variant => v)
		assert sv2.valid?
		sv2.sku = sv.sku
		assert sv2.invalid?
	end
	

end
