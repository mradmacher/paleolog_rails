require 'test_helper'

class UserControllerTest < ActionController::TestCase

  test "login page" do
    get :show_login

    assert_response :success
    assert_template 'show_login'

    assert_select 'form', :attributes => { :action => '/user/login',
      :method => 'post' }
    assert_select 'input', :attributes => { :name => 'user[login]',
      :type => 'text',
      :size => User::LOGIN_SIZE,
      :maxlength => User::LOGIN_MAX_LENGTH }
    assert_select 'input', :attributes => { :name => 'user[password]',
      :type => 'password',
      :size => User::PASSWORD_SIZE,
      :maxlength => User::PASSWORD_MAX_LENGTH }
    assert_select 'input', :attributes => { :type => 'submit',
      :value => 'Login' }
  end

  test "sending valid login and password" do
    user = User.sham!
    try_to_login( user )
    assert_response :redirect
    assert_redirected_to projects_url

    assert_not_nil session[:user_id]
    assert_equal 'You are logged in.', flash[:notice]

    assert_equal user.id, session[:user_id]
  end

  test "sending valid login and invalid password" do
    invalid_user = User.sham!
    invalid_user.password += 'invalid'
    try_to_login( invalid_user )
    assert_response :success

    assert_template 'show_login'

    assert_nil session[:user_id]
    assert_equal 'Invalid login/password.', flash[:notice]

    user = assigns( :user )
    assert_equal invalid_user.email, user.email
    assert_nil user.password
  end

  test "sending nonexistent login" do
    invalid_user = User.sham!
    invalid_user.email += 'invalid'
    try_to_login( invalid_user )
    assert_response :success

    assert_template 'show_login'

    assert_nil session[:user_id]
    assert_equal 'Invalid login/password.', flash[:notice]

    user = assigns(:user)
    assert_equal invalid_user.email, user.email
    assert_nil user.password
  end

  test "logging out" do
    try_to_login( User.sham! )
    assert_not_nil session[:user_id]
    get :logout
    assert_response :redirect
    assert_redirected_to root_url

    assert_nil session[:user_id]
    assert_equal 'You are logged out.', flash[:notice]
  end

  private

  def try_to_login( user )
    post :login, user: { login: user.login, password: user.password }
  end
end
