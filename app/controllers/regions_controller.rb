class RegionsController < ApplicationController
	before_filter :requires_user 
  before_filter :requires_admin, :except => [:index, :show]

	respond_to :html
	respond_to :json, :only => :index

	def index
		respond_with @regions = Region.all
	end

	def show
    @region = Region.find( params[:id] )
	end

	def new
		@region = Region.new
	end

	def edit
    @region = Region.find( params[:id] )
	end

	def create
    @region = Region.new( params[:region] )
    if @region.save
			flash[:notice] = 'Region was successfully created.'
			redirect_to( @region )
		else
			render :action => "new"
		end
	end

	def update
    @region = Region.find( params[:id], readonly: false ) 
		@region.assign_attributes( params[:region] )
    if @region.save
			flash[:notice] = 'Region was successfully updated.'
			redirect_to( @region )
		else
			render :action => "edit"
		end
	end

	def destroy
    @region = Region.find( params[:id] ) 
		if @region.wells.empty?
			@region.destroy
			flash[:notice] = 'Region was successfully deleted.'
			redirect_to regions_url
		else
			flash[:notice] = 'Cannot delete region with wells.'
			redirect_to region_url( @region ) 
		end
	end

end
