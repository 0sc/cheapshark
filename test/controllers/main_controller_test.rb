require 'test_helper'

class MainControllerTest < ActionController::TestCase
  test "should get verify" do
    get :verify
    assert_response :success
  end

  test "should get process" do
    get :process
    assert_response :success
  end

end
