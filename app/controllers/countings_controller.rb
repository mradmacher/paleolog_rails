class CountingsController < ApplicationController
	before_filter :requires_user

  def species
    @counting = Counting.viewable_by(current_user).find(params[:id])
    @section = Section.find(params[:section_id])
    respond_to do |format|
      format.json do
        render json: @counting.specimens_by_occurrence(@section.ordered_samples).map { |s| { id: s.id, name: s.name } }
      end
    end
  end

  def index
    @region = Region.viewable_by(current_user).find(params[:region_id])
    respond_to do |format|
      format.json do
        render json: @countings = @region.countings
      end
    end
  end

  def show
    @counting = Counting.viewable_by(current_user).find(params[:id])
		@region = @counting.region
  end

  def edit
    @counting = Counting.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @counting.manageable_by? current_user
		@region = @counting.region
  end

  def new
    @region = Region.find(params[:region_id])
    raise User::NotAuthorized unless @region.manageable_by?(current_user)
    @counting = Counting.new
    @counting.region = @region
  end

  def create
		@counting = Counting.new(counting_params)
    raise User::NotAuthorized unless @counting.manageable_by? current_user
    if @counting.save
      flash[:notice] = 'Counting was successfully created.'
      redirect_to(@counting)
    else
      render :action => "new"
    end
  end

  def update
    @counting = Counting.viewable_by(current_user).find(params[:id])
    raise User::NotAuthorized unless @counting.manageable_by? current_user
    @counting.assign_attributes(counting_params)
    if @counting.save
      flash[:notice] = 'Counting was successfully updated.'
      redirect_to(@counting)
    else
      render :action => "edit"
    end
  end

  def destroy
    @counting = Counting.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @counting.manageable_by? current_user
		@counting.destroy
    flash[:notice] = 'Counting was successfully deleted.'
    redirect_to region_url(@counting.region)
  end

  def counting_params
    params.require(:counting).permit(:name, :region_id, :group_id, :marker_id, :marker_count)
  end
end
