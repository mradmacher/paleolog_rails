class RegionsController < ApplicationController
	before_filter :requires_user
  before_filter :requires_admin, :except => [:index, :show]

	def index
    @regions = Region.all
    respond_to do |format|
      format.html
      format.json do
        render json: @regions
      end
    end
	end

	def show
    @region = Region.find(params[:id])
	end

	def new
		@region = Region.new
	end

	def edit
    @region = Region.find(params[:id])
	end

	def create
    @region = Region.new(region_params)
    if @region.save
			flash[:notice] = 'Region was successfully created.'
			redirect_to(@region)
		else
			render :action => "new"
		end
	end

	def update
    @region = Region.find(params[:id])
		@region.assign_attributes(region_params)
    if @region.save
			flash[:notice] = 'Region was successfully updated.'
			redirect_to(@region)
		else
			render :action => "edit"
		end
	end

	def destroy
    @region = Region.find(params[:id])
		if @region.wells.empty?
			@region.destroy
			flash[:notice] = 'Region was successfully deleted.'
			redirect_to regions_url
		else
			flash[:notice] = 'Cannot delete region with wells.'
			redirect_to region_url(@region)
		end
	end

  def region_params
    params.require(:region).permit(:name)
  end
end
