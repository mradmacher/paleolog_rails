module SiteHelper
  def site_navigation_for( view )
    menu = Menu.new
    case view
      when 'index'
        menu.add( 'Main menu', root_path )
      when 'about'
        menu.add( 'About', about_path )
      when 'help'
        menu.add( 'Help', help_path )
    end
    menu
  end
end
