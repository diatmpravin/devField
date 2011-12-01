require 'test_helper'

class OmxRequestsControllerTest < ActionController::TestCase
  setup do
    @omx_request = omx_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:omx_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create omx_request" do
    assert_difference('OmxRequest.count') do
      post :create, omx_request: @omx_request.attributes
    end

    assert_redirected_to omx_request_path(assigns(:omx_request))
  end

  test "should show omx_request" do
    get :show, id: @omx_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @omx_request.to_param
    assert_response :success
  end

  test "should update omx_request" do
    put :update, id: @omx_request.to_param, omx_request: @omx_request.attributes
    assert_redirected_to omx_request_path(assigns(:omx_request))
  end

  test "should destroy omx_request" do
    assert_difference('OmxRequest.count', -1) do
      delete :destroy, id: @omx_request.to_param
    end

    assert_redirected_to omx_requests_path
  end
end
