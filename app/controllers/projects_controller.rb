class ProjectsController < ApplicationController
	before_filter :requires_user

	def index
    @projects = Project.viewable_by(current_user)
    respond_to do |format|
      format.html
      format.json do
        render json: @projects
      end
    end
	end

	def show
    @project = Project.viewable_by(current_user).find(params[:id])
	end

	def new
		@project = Project.new
	end

	def edit
    @project = Project.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @project.manageable_by?(current_user)
	end

	def create
    @project = Project.new(project_params)
    if @project.save
      ResearchParticipation.create(project_id: @project.id, user_id: current_user.id, manager: true)
			flash[:notice] = 'Project was successfully created.'
			redirect_to(@project)
		else
			render :action => "new"
		end
	end

	def update
    @project = Project.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @project.manageable_by?(current_user)
		@project.assign_attributes(project_params)
    if @project.save
			flash[:notice] = 'Project was successfully updated.'
			redirect_to(@project)
		else
			render :action => "edit"
		end
	end

	def destroy
    @project = Project.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @project.manageable_by?(current_user)
		if @project.sections.empty?
			@project.destroy
			flash[:notice] = 'Project was successfully deleted.'
			redirect_to projects_url
		else
			flash[:notice] = 'Cannot delete project with sections.'
			redirect_to project_url(@project)
		end
	end

  def project_params
    params.require(:project).permit(:name)
  end
end
