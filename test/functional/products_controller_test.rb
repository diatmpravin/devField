require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @store = Factory(:store)
    @vendor = Factory(:vendor)
    @brand = Factory(:brand, :vendor => @vendor)
    @brand2 = Factory(:brand, :vendor => @vendor)
    @product = Factory(:product, :brand => @brand)
    @product2 = Factory(:product, :brand => @brand)
    @product3 = Factory(:product, :brand => @brand2)
    @product4 = Factory.build(:product)
    @product.add_to_store(@store)
    @product3.add_to_store(@store)
  end

  test "should get index" do
    # basic function, should be 3 products
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
    assert_select 'tr.product', 3
    
    # only 2 products are for same store
    get :index, :store_id => @store.id
    assert_response :success
    assert_not_nil assigns(:products)
    assert_select 'tr.product', 2
    
    # only 2 products are for the given brand
    get :index, :brand_id => @brand.id
    assert_response :success
    assert_not_nil assigns(:products)
    assert_select 'tr.product', 2
    
    # only 1 product for this combination of brand and store
    get :index, :brand_id => @brand.id, :store_id => @store.id
    assert_response :success
    assert_not_nil assigns(:products)
    assert_select 'tr.product', 1
    
    # 3 products across 2 brands for this vendor
    get :index, :vendor_id => @vendor.id
    assert_response :success
    assert_not_nil assigns(:products)
    assert_select 'tr.product', 3
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product" do
    assert_difference('Product.count') do
      post :create, product: @product4.attributes
    end

    assert_redirected_to product_path(assigns(:product))
  end

  test "should show product" do
    get :show, id: @product.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product.to_param
    assert_response :success
  end

  test "should update product" do
    put :update, id: @product.to_param, product: @product.attributes
    assert_redirected_to product_path(assigns(:product))
  end

  #test "should append product to external" do
  #  put :to_external, id: @product.to_param, product: @product.attributes, store_id: @store.to_param
  #  assert_redirected_to product_path(assigns(:product))
  #end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, id: @product.to_param
    end

    assert_redirected_to products_path
  end
end
