require 'test_helper'

class OmxRequestsControllerTest < ActionController::TestCase
  setup do
    @omx_request = omx_requests(:one)
  end

  test "should show omx_request" do
    get :show, id: @omx_request.to_param
    assert_response :success
  end

end
