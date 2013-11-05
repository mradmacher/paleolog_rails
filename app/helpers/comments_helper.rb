module CommentsHelper
  def commentable_path( comment )
    case comment.commentable_type
      when Image.to_s
        image_path( comment.commentable_id )
      when Specimen.to_s
        specimen_path( comment.commentable_id )
    end
  end
  def commentables_path( comment )
    case comment.commentable_type
      when Specimen.to_s
        specimens_path
      when Image.to_s
        specimens_path
    end
  end
  def edit_commentable_comment_path( comment )
    case comment.commentable_type
      when Image.to_s
        edit_image_comment_path( comment.commentable_id, comment.id )
      when Specimen.to_s
        edit_specimen_comment_path( comment.commentable_id, comment.id )
    end
  end

  def comment_content_menu_for( view )
    menu = Menu.new
    case view
      when 'show'
        menu.add( 'Back', commentable_path( @comment ) ) 
        menu.add_menu( @comment.commentable.class.to_s ) do |m|
          m.add( 'Show', commentable_path( @comment ) )
        end
        menu.add_menu( 'Images' ) do |m|
          m.add( 'Original', @comment.comment.url ) 
          m.add( 'Edit', edit_commentable_comment_path( 
              @comment.commentable_id, @comment.id ) ) if 
              @logged_user.has_privilege? Privilege::EDITING
          m.add( 'Delete', comment_path( @comment.id ), 
              :confirm => 'Are you sure?', :method => :delete ) if 
              @logged_user.has_privilege? Privilege::EDITING
        end
      when 'edit'
        menu.add( 'Back', commentable_path( @comment ) )
      when 'new'
        menu.add( 'Back', commentable_path( @comment ) )
    end
    menu
  end

  def comment_navigation_for( view )
    menu = Menu.new
    case view
      when 'index'
        case @commentable_type
          when Specimen.to_s
            menu.add( 'Comments for Specimens', comments_path( :type => Specimens.to_s ) )
          when Image.to_s
            menu.add( 'Comments for Images', comments_path( :type => Image.to_s ) )
          else
            menu.add( 'Comments', comments_path )
        end
      when 'edit'
        menu.add( @comment.commentable.class.to_s, commentables_path( @comment ) )
        menu.add( @comment.commentable.name, commentable_path( @comment ) )
        menu.add( 'Editing comment', edit_comment_path( @comment ) )
     end
     menu
  end

end
