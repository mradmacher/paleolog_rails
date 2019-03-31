class SpecimensController < ApplicationController
	before_filter :requires_user
  before_filter :requires_admin, :except => [:index, :show, :search]

  def search
    @specimens = Specimen.search(params)
    respond_to do |format|
      format.html
      format.json do
        render json: @specimens.map { |s| { id: s.id, name: s.name }}
      end
    end
  end

  def index
    @specimens = params.keys.any? { |k| k.in?(['group_id', 'project_id', 'name']) } ? Specimen.all : Specimen.where('1<>1')
    unless params[:group_id].blank?
      @group = Group.find( params[:group_id] )
			@specimens = @specimens.where(group_id: @group.id)
			@group_id = @group.id
    end
    unless params[:project_id].blank?
      @project = Project.find(params[:project_id])
			@project_id = @project.id
      occurrence_specimen_ids = Occurrence.joins(:counting).where('countings.project_id' => @project_id).select(:specimen_id).distinct.map(&:specimen_id)
      image_specimen_ids = Image.joins(sample: :section).where('sections.project_id' => @project_id).select(:specimen_id).distinct.map(&:specimen_id)
      specimen_ids = occurrence_specimen_ids + image_specimen_ids
			@specimens = @specimens.where(id: specimen_ids)
    end
		@images_visible = params[:images].nil? ? false : true
		unless params[:name].blank?
      @name_pattern = params[:name] || ''
			@specimens = @specimens.where('specimens.name like ?', '%' + @name_pattern + '%')
		end
		#@specimens = Specimen.where( '1<>1' ) if @specimens.nil?
    @specimens = @specimens.order(:name)
    respond_to do |format|
      format.html
      format.json do
        render json: @specimens
      end
    end
  end

  def show
    @specimen = Specimen.find(params[:id])
    @commentable = @specimen
    @comment = Comment.new( :commentable_id => @specimen.id,
        :commentable_type => Specimen.to_s,
        :user_id => session[:user_id] )
    @comments = @specimen.comments.all.order('updated_at desc')
  end

  def new
    @specimen = Specimen.new
  end

  def edit
    @specimen = Specimen.find(params[:id])
  end

  def create
    @specimen = Specimen.new(specimen_params)

    if @specimen.save
      flash[:notice] = 'Specimen was successfully created.'
      redirect_to(@specimen)
    else
      render :action => "new"
    end
  end

  def update
    @specimen = Specimen.find(params[:id])
    if @specimen.update_attributes(specimen_params)
      flash[:notice] = 'Specimen was successfully updated.'
      redirect_to(@specimen)
    else
      render :action => "edit"
    end
  end

  def destroy
    @specimen = Specimen.find(params[:id])
    @specimen.destroy
    redirect_to specimens_url
  end

  def specimen_params
    params.require(:specimen).permit(
      :name,
      :verified,
      :description,
      :environmental_preferences,
      :group_id
    )
  end
end
