require 'test_helper'

class BrandsControllerTest < ActionController::TestCase

  setup do
    @brand = Factory(:brand)
    @brand2 = Factory.build(:brand)
    @store = Factory(:store, :store_type => 'MWS')
    @product1 = Factory(:product, :brand => @brand)
    @product2 = Factory(:product, :brand => @brand)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:brands)
	end
	
	test "should redirect to specific brand if name passed" do    
    get :index, :name => @brand.name
    assert_redirected_to @brand
  end

	test "should get by_name" do    
    get :by_name, :name => @brand.name
    assert_redirected_to @brand
  end
  
  test "by_name should revert to index if no name is given" do  
    get :by_name
    assert_redirected_to brands_url    
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create brand" do
    assert_difference('Brand.count') do
      post :create, brand: @brand2.attributes
    end

    assert_redirected_to brands_path
  end

  test "should show brand" do
    get :show, id: @brand.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @brand.to_param
    assert_response :success
  end

  test "should update brand" do
    put :update, id: @brand.to_param, brand: @brand.attributes
    assert_redirected_to brands_path
  end

  test "should destroy brand" do
    assert_difference('Brand.count', -1) do
      delete :destroy, id: @brand.to_param
    end

    assert_redirected_to brands_path
  end

  test "should add brand to store" do
    put :add_to_store, id: @brand.to_param, store_id: @store.to_param
    assert_redirected_to brands_path
  end
  
  test "should remove brand from store" do
    put :remove_from_store, id: @brand.to_param, store_id: @store.to_param
    assert_redirected_to brands_path
  end
end
