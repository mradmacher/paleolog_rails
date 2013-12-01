class WellsController < ApplicationController
	before_filter :requires_user 

	respond_to :html
	respond_to :json, :only => :index

	def index
    @region = Region.find( params[:region_id] )
		respond_with @wells = @region.wells.viewable_by( current_user )
	end

	def show
    @well = Well.viewable_by( current_user ).find( params[:id] )
		@region = @well.region
	end

	def new
    @region = Region.find( params[:region_id] )
    @well = Well.new
    @well.region = @region
	end

	def edit
    @well = Well.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @well.manageable_by? current_user
		@region = @well.region
	end

	def create
		@well = Well.new(params[:well])
    if @well.save
      ResearchParticipation.create( well_id: @well.id, user_id: current_user.id, manager: true )
      flash[:notice] = 'Well was successfully created.'
      redirect_to( @well )
    else
      render :action => "new" 
    end
	end

	def update
    @well = Well.viewable_by( current_user ).find( params[:id], readonly: false )
    raise User::NotAuthorized unless @well.manageable_by? current_user
    @well.assign_attributes( params[:well] )
    if @well.save
      flash[:notice] = 'Well was successfully updated.'
      redirect_to( @well )
    else
      render :action => "edit" 
    end
	end

	def destroy
    @well = Well.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @well.manageable_by? current_user
		if @well.samples.empty?
			@well.destroy
			flash[:notice] = 'Well was successfully deleted.'
			redirect_to region_url( @well.region )
		else
			flash[:notice] = 'Can not delete well with samples.'
			redirect_to well_url( @well ) 
		end
	end

end