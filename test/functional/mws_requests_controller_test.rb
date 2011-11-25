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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mws_request" do
    assert_difference('MwsRequest.count') do
      post :create, mws_request: @mws_request.attributes
    end

    assert_redirected_to mws_request_path(assigns(:mws_request))
  end

  test "should show mws_request" do
    get :show, id: @mws_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mws_request.to_param
    assert_response :success
  end

  test "should update mws_request" do
    put :update, id: @mws_request.to_param, mws_request: @mws_request.attributes
    assert_redirected_to mws_request_path(assigns(:mws_request))
  end

  test "should destroy mws_request" do
    assert_difference('MwsRequest.count', -1) do
      delete :destroy, id: @mws_request.to_param
    end

    assert_redirected_to mws_requests_path
  end
end
