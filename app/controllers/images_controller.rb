class ImagesController < ApplicationController
	before_filter :requires_user 
  before_filter :requires_admin, :except => [:index, :show]

  def index
    @specimen = Dinoflagellate.find( params[:specimen_id] )
    @images = Image.all( :conditions => { :specimen_id => @specimen.id } )
  end

  def show
    @image = Image.find(params[:id])
    @other_images = @image.specimen.images
    if params[:size] == 'oryginal' 
      render 'show_oryginal', :layout => false
    end
    @commentable = @image
    @comment = Comment.new( :commentable_id => @image.id,
        :commentable_type => Image.to_s,
        :user_id => session[:user_id] )
    @comments = @image.comments.find( :all, :order => 'updated_at desc' )
  end

  def new
    @image = Image.new
    @image.specimen_id = params[:specimen_id]
  end

  def edit
    @image = Image.find(params[:id])
    @samples = Sample.all
  end

  def create
    @image = Image.new(params[:image])

    if @image.save
      flash[:notice] = 'Image was successfully created.'
      redirect_to image_url( @image )
    else
      render :action => "new"
    end
  end

  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(params[:image])
      flash[:notice] = 'Image was successfully updated.'
      redirect_to image_url( @image.id )
    else
      render :action => "edit"
    end
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    redirect_to specimen_url( @image.specimen_id )
  end
end