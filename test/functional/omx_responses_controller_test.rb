require 'test_helper'

class OmxResponsesControllerTest < ActionController::TestCase
  setup do
    @omx_response = omx_responses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:omx_responses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create omx_response" do
    assert_difference('OmxResponse.count') do
      post :create, omx_response: @omx_response.attributes
    end

    assert_redirected_to omx_response_path(assigns(:omx_response))
  end

  test "should show omx_response" do
    get :show, id: @omx_response.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @omx_response.to_param
    assert_response :success
  end

  test "should update omx_response" do
    put :update, id: @omx_response.to_param, omx_response: @omx_response.attributes
    assert_redirected_to omx_response_path(assigns(:omx_response))
  end

  test "should destroy omx_response" do
    assert_difference('OmxResponse.count', -1) do
      delete :destroy, id: @omx_response.to_param
    end

    assert_redirected_to omx_responses_path
  end
end
