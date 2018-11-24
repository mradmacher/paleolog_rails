class WellsController < ApplicationController
	before_filter :requires_user

	def index
    @region = Region.find(params[:region_id])
    respond_to do |format|
      format.json do
        render json: @wells = @region.wells.viewable_by( current_user )
      end
    end
	end

	def show
    @well = Well.viewable_by(current_user).find(params[:id])
		@region = @well.region
    @countings = @region.countings
    @samples = @well.samples
    @counted_samples = Occurrence.where(counting_id: @countings.map(&:id), sample_id: @samples.map(&:id))
      .select(:counting_id, :sample_id).distinct.map { |o| [o.counting_id, o.sample_id] }
	end

	def new
    @region = Region.find(params[:region_id])
    @well = Well.new
    @well.region = @region
	end

	def edit
    @well = Well.viewable_by(current_user).find( params[:id] )
    raise User::NotAuthorized unless @well.manageable_by? current_user
		@region = @well.region
	end

	def create
		@well = Well.new(well_params)
    if @well.save
      flash[:notice] = 'Well was successfully created.'
      redirect_to( @well )
    else
      render :action => "new"
    end
	end

	def update
    @well = Well.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @well.manageable_by? current_user
    @well.assign_attributes(well_params)
    if @well.save
      flash[:notice] = 'Well was successfully updated.'
      redirect_to( @well )
    else
      render :action => "edit"
    end
	end

	def destroy
    @well = Well.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @well.manageable_by? current_user
		if @well.samples.empty?
			@well.destroy
			flash[:notice] = 'Well was successfully deleted.'
			redirect_to region_url(@well.region)
		else
			flash[:notice] = 'Can not delete well with samples.'
			redirect_to well_url(@well)
		end
	end

  def well_params
    params.require(:well).permit(:name, :region_id)
  end
end
