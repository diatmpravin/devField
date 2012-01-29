require 'test_helper'

class ProductsStoresControllerTest < ActionController::TestCase
  setup do
    @store = Factory(:store, :store_type => 'Shopify')
    @product = Factory(:product)
    @product2 = Factory(:product)
    @ps = Factory.build(:products_store, :store => @store, :product => @product)
    @ps2 = Factory(:products_store, :store => @store, :product => @product2)
  end

  test "should create products_store" do
    assert_difference('ProductsStore.count') do
      post :create, products_store: @ps.attributes
    end
    
    #TODO delete created product to avoid collecting too many in test store
    #assert_difference('ProductsStore.count',-1) do    
    #	delete :destroy, id: @ps.to_param
    #end
    
		#TODO assert_redirected_to product_path(assigns(:product))
  end

  test "should destroy products_store" do
    assert_difference('ProductsStore.count', -1) do
      delete :destroy, id: @ps2.to_param
    end

    assert_redirected_to products_path
  end
end
