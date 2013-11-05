module UserHelper
  def user_navigation_for( view )
    menu = Menu.new
    menu.add( 'Logging', login_path )
    menu
  end
end
