class UserController < ApplicationController
  skip_before_filter :requires_user, :only => :login

  def login
    @title = 'Login'

    @user = User.new(user_params)
    user = User.find_by_login_and_password(@user.login, @user.password)
    if user
      session[:user_id] = user.id
      flash[:notice] = 'You are logged in.'
      redirect_to projects_url
    else
      session[:user_id] = nil
      @user.password = nil
      flash[:notice] = 'Invalid login/password.'
      render :show_login
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = 'You are logged out.'
    redirect_to root_url
  end

  def user_params
    params.require(:user).permit(:login, :password)
  end
end
