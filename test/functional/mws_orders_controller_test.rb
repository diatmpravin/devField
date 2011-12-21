require 'test_helper'

class MwsOrdersControllerTest < ActionController::TestCase
  setup do
    @mws_order = mws_orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mws_orders)
  end

  test "should show mws_order" do
    get :show, id: @mws_order.to_param
    assert_response :success
  end

  test "should update mws_order" do
    put :update, id: @mws_order.to_param, mws_order: @mws_order.attributes
    assert_redirected_to mws_order_path(assigns(:mws_order))
  end
  
end
