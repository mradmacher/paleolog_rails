class SectionsController < ApplicationController
	before_filter :requires_user

	def index
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.json do
        render json: @sections = @project.sections.viewable_by( current_user )
      end
    end
	end

	def show
    @section = Section.viewable_by(current_user).find(params[:id])
		@project = @section.project
    @countings = @project.countings
    @samples = @section.samples.ordered
    @counted_samples = Occurrence.where(counting_id: @countings.map(&:id), sample_id: @samples.map(&:id))
      .select(:counting_id, :sample_id).distinct.map { |o| [o.counting_id, o.sample_id] }
	end

	def new
    @project = Project.find(params[:project_id])
    @section = Section.new
    @section.project = @project
	end

	def edit
    @section = Section.viewable_by(current_user).find( params[:id] )
    raise User::NotAuthorized unless @section.manageable_by? current_user
		@project = @section.project
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
			redirect_to project_url(@section.project)
		else
			flash[:notice] = 'Can not delete section with samples.'
			redirect_to section_url(@section)
		end
	end

  def section_params
    params.require(:section).permit(:name, :category, :project_id)
  end
end
