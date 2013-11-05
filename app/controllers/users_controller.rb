class UsersController < ApplicationController
  before_filter :requires_admin

  def add_role
    user = User.find( params[:user_id] )
    role = Role.find( params[:role_id] )
    user.roles << role
    user.save
  end
  def remove_role
    user = User.find( params[:user_id] )
    role = Role.find( params[:role_id] )
    user.roles.delete( role )
    user.save
  end

  def index
    @users = User.all( :order => 'name asc' )
  end

  def show
    @user = User.find( params[:id] )
  end

  def new
    @user = User.new
  end

  def edit
    @editing_roles = params[:section] == 'roles' ? true : false
    @user = User.find( params[:id] )

    @user.password = nil
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to( @user )
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])
    if params[:user].has_key? :role_ids
      params[:user][:role_ids].delete_if { |k, v| v == '0' }
      params[:user][:role_ids] = params[:user][:role_ids].keys
    end
    if params[:user][:password].blank? then 
      params[:user][:password] = @user.password
      params[:user][:password_confirmation] = @user.password
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to( @user )
    else
      render :action => "edit"
    end
  end
end
