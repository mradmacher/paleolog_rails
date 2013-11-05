class FeaturesController < ApplicationController
	before_filter :requires_user 
  before_filter :requires_admin

  def create
    @feature = Feature.new(params[:feature])

    if @feature.save
      flash[:notice] = 'Feature was successfully created.'
    end
    puts @feature.errors.full_messages
    redirect_to specimen_url( @feature.specimen )
  end

  def update
    @feature = Feature.find( params[:id] )
    if @feature.update_attributes(params[:feature])
      flash[:notice] = 'Feature was successfully updated.'
    end
    redirect_to specimen_url( @feature.specimen )
  end

  def destroy
    @feature = Feature.find( params[:id] )
    if @feature.destroy
      flash[:notice] = 'Feature was successfully deleted.'
    end
    redirect_to specimen_url( @feature.specimen )
  end
end

