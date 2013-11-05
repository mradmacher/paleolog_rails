class CommentsController < ApplicationController
	before_filter :requires_user 

  def index
    if !params[:image_id].nil? 
      commentable_id = params[:image_id]
      commentable_type = Image.to_s
      @commentable = Image.find( commentable_id )
    elsif !params[:specimen_id].nil? 
      commentable_id = params[:specimen_id]
      commentable_type = Specimen.to_s
      @commentable = Specimen.find( commentable_id )
    elsif !params[:type].nil?
      case params[:type] 
        when Image.to_s
          @commentable_type = Image.to_s
        when Specimen.to_s
          @commentable_type = Specimen.to_s
      end
    end
    if !commentable_id.nil? && !commentable_type.nil? 
      @comments = Comment.find( :all, :conditions => {
          :commentable_id => commentable_id, 
          :commentable_type => commentable_type },
        :order => 'updated_at desc' )
      @comment = Comment.new( :commentable_id => commentable_id,
          :commentable_type => commentable_type,
          :user_id => current_user.id )
    elsif !@commentable_type.nil? 
      @comments = Comment.find( :all, :conditions => {
          :commentable_type => @commentable_type },
        :order => 'updated_at desc' )
    else
      @comments = Comment.find( :all, :order => 'updated_at desc' )
    end
  end

  def show
    @comment = Comment.find(params[:id])
  end

  def new
    @comment = Comment.new
    @comment.user = current_user
    if !params[:image_id].nil? 
      @comment.commentable_id = params[:image_id]
      @comment.commentable_type = Image.to_s
    elsif !params[:specimen_id].nil? 
      @comment.commentable_id = params[:specimen_id]
      @comment.commentable_type = Specimen.to_s
    end
  end

  def edit
    @comment = Comment.find(params[:id])
  end

  def create
    @comment = Comment.new(params[:comment])

    if @comment.save
      case @comment.commentable_type
        when Specimen.to_s
          redirect_to specimen_url( @comment.commentable_id )
        when Image.to_s
          redirect_to image_url( @comment.commentable_id )
        else
          redirect_to comment_url( @comment.id )
      end
      #redirect_to(@comment, :notice => 'Comment was successfully created.')
    else
      render :action => "new" 
    end
  end

  def update
    @comment = Comment.find(params[:id])

    if @comment.update_attributes(params[:comment])
      case @comment.commentable_type
        when Specimen.to_s
          redirect_to specimen_url( @comment.commentable_id )
        when Image.to_s
          redirect_to image_url( @comment.commentable_id )
        else
          redirect_to comment_url( @comment.id )
      end
      #redirect_to(@comment, :notice => 'Comment was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    case @comment.commentable_type
      when Specimen.to_s
        redirect_to specimen_url( @comment.commentable_id )
      when Image.to_s
        redirect_to image_url( @comment.commentable_id )
      else
        redirect_to comment_url( @comment.id )
    end

    #redirect_to(comments_url)
  end
end
