require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get personalpage" do
    get :personalpage
    assert_response :success
  end

  test "should get coursepage" do
    get :coursepage
    assert_response :success
  end

  test "should get posting" do
    get :posting
    assert_response :success
  end

  test "should get login" do
    get :login
    assert_response :success
  end

end
