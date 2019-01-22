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
    @comments = @image.comments.all.order('updated_at desc')
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
    @image = Image.new(image_params)

    if @image.save
      flash[:notice] = 'Image was successfully created.'
      redirect_to specimen_url(@image.specimen_id)
    else
      render :action => "new"
    end
  end

  def update
    @image = Image.find(params[:id])

    if @image.update_attributes(image_params)
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

  def image_params
    params.require(:image).permit(:specimen_id, :sample_id, :ef, :image)
  end
end
