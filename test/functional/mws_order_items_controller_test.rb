require 'test_helper'

class MwsOrderItemsControllerTest < ActionController::TestCase
  setup do
    @mws_order_item = mws_order_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mws_order_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mws_order_item" do
    assert_difference('MwsOrderItem.count') do
      post :create, mws_order_item: @mws_order_item.attributes
    end

    assert_redirected_to mws_order_item_path(assigns(:mws_order_item))
  end

  test "should show mws_order_item" do
    get :show, id: @mws_order_item.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mws_order_item.to_param
    assert_response :success
  end

  test "should update mws_order_item" do
    put :update, id: @mws_order_item.to_param, mws_order_item: @mws_order_item.attributes
    assert_redirected_to mws_order_item_path(assigns(:mws_order_item))
  end

  test "should destroy mws_order_item" do
    assert_difference('MwsOrderItem.count', -1) do
      delete :destroy, id: @mws_order_item.to_param
    end

    assert_redirected_to mws_order_items_path
  end
end
