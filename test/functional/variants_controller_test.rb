require 'test_helper'

class VariantsControllerTest < ActionController::TestCase
  setup do
    @variant = Factory(:variant)
    #@variant.sku = 'unique_sku'
    @variant2 = Factory.build(:variant)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:variants)
  end
  
  test "should redirect to specific variant if sku passed" do
  	get :index, :sku => @variant.sku
  	assert_redirected_to @variant
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create variant" do
    assert_difference('Variant.count') do
      post :create, variant: @variant2.attributes
    end

    assert_redirected_to variant_path(assigns(:variant))
  end

  test "should show variant" do
    get :show, id: @variant.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @variant.to_param
    assert_response :success
  end

  test "should update variant" do
    put :update, id: @variant.to_param, variant: @variant.attributes
    assert_redirected_to variant_path(assigns(:variant))
  end

  test "should destroy variant" do
    assert_difference('Variant.count', -1) do
      delete :destroy, id: @variant.to_param
    end

    assert_redirected_to variants_path
  end
end
