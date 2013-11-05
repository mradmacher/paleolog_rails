class CountingsController < ApplicationController
	before_filter :requires_user 

	respond_to :json, :only => [:index, :species]

  def species
    @counting = Counting.viewable_by( current_user ).find( params[:id] )
    respond_with @counting.specimens_by_occurrence.map{ |s| { :id => s.id, :name => s.name} }
  end

  def index
    @well = Well.viewable_by( current_user ).find( params[:well_id] )
		respond_with @countings = @well.countings.viewable_by( current_user )
  end

  def show
    @counting = Counting.viewable_by( current_user ).find( params[:id] )
		@well = @counting.well
  end

  def edit
    @counting = Counting.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @counting.manageable_by? current_user
		@well = @counting.well
  end

  def new
    @well = Well.find( params[:well_id] )
    raise User::NotAuthorized unless @well.manageable_by? current_user
    @counting = Counting.new
    @counting.well = @well
  end

  def create
		@counting = Counting.new( params[:counting] )
    raise User::NotAuthorized unless @counting.manageable_by? current_user
    if @counting.save
      flash[:notice] = 'Counting was successfully created.'
      redirect_to( @counting )
    else
      render :action => "new" 
    end
  end

  def update
    @counting = Counting.viewable_by( current_user ).find( params[:id], readonly: false )
    raise User::NotAuthorized unless @counting.manageable_by? current_user
    @counting.assign_attributes( params[:counting] )
    if @counting.save
      flash[:notice] = 'Counting was successfully updated.'
      redirect_to( @counting )
    else
      render :action => "edit" 
    end
  end

  def destroy
    @counting = Counting.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @counting.manageable_by? current_user
		@counting.destroy
    flash[:notice] = 'Counting was successfully deleted.'
    redirect_to well_url( @counting.well )
  end

end

