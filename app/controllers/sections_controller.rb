class SectionsController < ApplicationController
	before_filter :requires_user

	def index
    @region = Region.find(params[:region_id])
    respond_to do |format|
      format.json do
        render json: @sections = @region.sections.viewable_by( current_user )
      end
    end
	end

	def show
    @section = Section.viewable_by(current_user).find(params[:id])
		@region = @section.region
    @countings = @region.countings
    @samples = @section.samples
    @counted_samples = Occurrence.where(counting_id: @countings.map(&:id), sample_id: @samples.map(&:id))
      .select(:counting_id, :sample_id).distinct.map { |o| [o.counting_id, o.sample_id] }
	end

	def new
    @region = Region.find(params[:region_id])
    @section = Section.new
    @section.region = @region
	end

	def edit
    @section = Section.viewable_by(current_user).find( params[:id] )
    raise User::NotAuthorized unless @section.manageable_by? current_user
		@region = @section.region
	end

	def create
		@section = Section.new(section_params)
    if @section.save
      flash[:notice] = 'Section was successfully created.'
      redirect_to( @section )
    else
      render :action => "new"
    end
	end

	def update
    @section = Section.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @section.manageable_by? current_user
    @section.assign_attributes(section_params)
    if @section.save
      flash[:notice] = 'Section was successfully updated.'
      redirect_to( @section )
    else
      render :action => "edit"
    end
	end

	def destroy
    @section = Section.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @section.manageable_by? current_user
		if @section.samples.empty?
			@section.destroy
			flash[:notice] = 'Section was successfully deleted.'
			redirect_to region_url(@section.region)
		else
			flash[:notice] = 'Can not delete section with samples.'
			redirect_to section_url(@section)
		end
	end

  def section_params
    params.require(:section).permit(:name, :region_id)
  end
end
