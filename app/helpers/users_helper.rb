module UsersHelper
  def user_content_menu_for( view )
    Menu.new
  end

  def user_navigation_for( view )
    menu = Menu.new
    menu.add( 'Users', users_path )
    case view
      when 'show'
        menu.add( @user.name, user_path( @user ) )
      when 'edit'
        menu.add( @user.name, user_path( @user ) )
        menu.add( 'Editing', edit_user_path( @user ) )
      when 'new'
        menu.add( 'Creating', new_user_path )
    end
    menu
  end
end
