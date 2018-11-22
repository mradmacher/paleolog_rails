class SamplesController < ApplicationController
	before_filter :requires_user

	def index
    @well = Well.find( params[:well_id] )
    respond_to do |format|
      format.json do
        render json: @samples = @well.samples.viewable_by(current_user)
      end
    end
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
		@sample = Sample.new(sample_params)
    raise User::NotAuthorized unless @sample.manageable_by? current_user
    if @sample.save
      flash[:notice] = 'Sample was successfully created.'
      redirect_to( @sample )
    else
      render :action => "new"
    end
	end

	def update
    @sample = Sample.viewable_by( current_user ).find(params[:id])
    raise User::NotAuthorized unless @sample.manageable_by? current_user
    @sample.assign_attributes(sample_params)
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

  def sample_params
    params.require(:sample).permit(:name, :well_id, :bottom_depth, :top_depth, :description, :weight)
  end
end
