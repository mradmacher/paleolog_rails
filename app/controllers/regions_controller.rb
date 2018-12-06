class RegionsController < ApplicationController
	before_filter :requires_user

	def index
    @regions = Region.viewable_by(current_user)
    respond_to do |format|
      format.html
      format.json do
        render json: @regions
      end
    end
	end

	def show
    @region = Region.viewable_by(current_user).find(params[:id])
	end

	def new
		@region = Region.new
	end

	def edit
    @region = Region.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @region.manageable_by?(current_user)
	end

	def create
    @region = Region.new(region_params)
    if @region.save
      ResearchParticipation.create(region_id: @region.id, user_id: current_user.id, manager: true)
			flash[:notice] = 'Region was successfully created.'
			redirect_to(@region)
		else
			render :action => "new"
		end
	end

	def update
    @region = Region.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @region.manageable_by?(current_user)
		@region.assign_attributes(region_params)
    if @region.save
			flash[:notice] = 'Region was successfully updated.'
			redirect_to(@region)
		else
			render :action => "edit"
		end
	end

	def destroy
    @region = Region.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @region.manageable_by?(current_user)
		if @region.sections.empty?
			@region.destroy
			flash[:notice] = 'Region was successfully deleted.'
			redirect_to regions_url
		else
			flash[:notice] = 'Cannot delete region with sections.'
			redirect_to region_url(@region)
		end
	end

  def region_params
    params.require(:region).permit(:name)
  end
end
