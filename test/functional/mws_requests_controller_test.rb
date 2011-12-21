require 'test_helper'

class MwsRequestsControllerTest < ActionController::TestCase
  setup do
    @mws_request = mws_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mws_requests)
  end

  test "should show mws_request" do
    get :show, id: @mws_request.to_param
    assert_response :success
  end
  
end
