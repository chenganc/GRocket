require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  #setup do
  #  @user = users(:one)
  #end
  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { firstName: @user.firstName, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_path
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_path
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
      assert_redirected_to root_path
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_path
  end
end
