class SamplesController < ApplicationController
	before_filter :requires_user

	def index
    @section = Section.find( params[:section_id] )
    respond_to do |format|
      format.json do
        render json: @samples = @section.samples.viewable_by(current_user)
      end
    end
	end

	def show
    @sample = Sample.viewable_by(current_user).find(params[:id])
		@section = @sample.section
    @project = @section.project
	end

	def new
    @section = Section.find( params[:section_id] )
    raise User::NotAuthorized unless @section.manageable_by?(current_user)
    @project = @section.project
    @sample = Sample.new
    @sample.section = @section
	end

	def edit
    @sample = Sample.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @sample.manageable_by?(current_user)
		@section = @sample.section
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
			redirect_to section_url( @sample.section )
		else
			flash[:notice] = 'Can not delete sample with sample countings.'
			redirect_to sample_url( @sample )
		end
	end

  def sample_params
    params.require(:sample).permit(:name, :section_id, :bottom_depth, :top_depth, :description, :weight)
  end
end
