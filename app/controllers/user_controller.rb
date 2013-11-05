class UserController < ApplicationController
  skip_before_filter :requires_user, :only => :login

  def login
    @title = 'Login'

    if request.post? and params[:user]
      @user = User.new( params[:user] )
      user = User.find_by_login_and_password( @user.login, @user.password )
      if user
        session[:user_id] = user.id
#        session[:privileges] = user.privileges 
        flash[:notice] = 'You are logged in.'
        redirect_to root_url
      else
        session[:user_id] = nil
        @user.password = nil
        flash[:notice] = 'Invalid login/password.'
      end
    end
  end

  def logout
    session[:user_id] = nil
#    session[:privileges] = nil
    flash[:notice] = 'You are logged out.'
    redirect_to root_url( subdomain: false )
  end

end
