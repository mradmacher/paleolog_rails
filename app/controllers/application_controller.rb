class ApplicationController < ActionController::Base
	before_filter :set_current_user

	protect_from_forgery :only => [:create, :update, :destroy]
	helper_method :current_user, :current_user?

  rescue_from User::NotAuthorized, :with => :user_not_authorized if Rails.env != 'test'

	protected
	def set_current_user
		unless session[:user_id].nil?
			@logged_user = User.find( session[:user_id] )
		end
	end

  def current_user
    @logged_user
  end
  def current_user?
    !@logged_user.nil?
  end

	def requires_user
		raise User::NotAuthorized unless current_user
	end

  def requires_admin
    raise User::NotAuthorized unless current_user && current_user.admin?
  end

  def user_not_authorized
    flash[:notice] = "You are not authorized to do that operation."
    redirect_to root_url
  end

end

