class SamplesController < ApplicationController
	before_filter :requires_user 

	respond_to :json, :only => :index

	def index
    @well = Well.find( params[:well_id] )
		respond_with @samples = @well.samples.viewable_by( current_user )
	end

	def show
    @sample = Sample.viewable_by( current_user ).find( params[:id] )
		@well = @sample.well
	end

	def new
    @well = Well.find( params[:well_id] )
    raise User::NotAuthorized unless @well.manageable_by? current_user
    @sample = Sample.new
    @sample.well = @well
	end

	def edit
    @sample = Sample.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @sample.manageable_by? current_user
		@well = @sample.well
	end

	def create
		@sample = Sample.new(params[:sample])
    raise User::NotAuthorized unless @sample.manageable_by? current_user
    if @sample.save
      flash[:notice] = 'Sample was successfully created.'
      redirect_to( @sample )
    else
      render :action => "new" 
    end
	end

	def update
    @sample = Sample.viewable_by( current_user ).find( params[:id], readonly: false )
    raise User::NotAuthorized unless @sample.manageable_by? current_user
    @sample.assign_attributes( params[:sample] )
    if @sample.save
      flash[:notice] = 'Sample was successfully updated.'
      redirect_to( @sample )
    else
      render :action => "edit" 
    end
	end

	def destroy
    @sample = Sample.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @sample.manageable_by? current_user
		if @sample.occurrences.empty?
			@sample.destroy
			flash[:notice] = 'Sample was successfully deleted.'
			redirect_to well_url( @sample.well )
		else
			flash[:notice] = 'Can not delete sample with sample countings.'
			redirect_to sample_url( @sample ) 
		end
	end
  
end
