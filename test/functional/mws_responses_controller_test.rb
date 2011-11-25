require 'test_helper'

class MwsResponsesControllerTest < ActionController::TestCase
  setup do
    @mws_response = mws_responses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mws_responses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mws_response" do
    assert_difference('MwsResponse.count') do
      post :create, mws_response: @mws_response.attributes
    end

    assert_redirected_to mws_response_path(assigns(:mws_response))
  end

  test "should show mws_response" do
    get :show, id: @mws_response.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mws_response.to_param
    assert_response :success
  end

  test "should update mws_response" do
    put :update, id: @mws_response.to_param, mws_response: @mws_response.attributes
    assert_redirected_to mws_response_path(assigns(:mws_response))
  end

  test "should destroy mws_response" do
    assert_difference('MwsResponse.count', -1) do
      delete :destroy, id: @mws_response.to_param
    end

    assert_redirected_to mws_responses_path
  end
end
