module ReportsHelper
  def report_content_menu_for( view )
    menu = Menu.new
    menu
  end

  def report_navigation_for( view )
    menu = Menu.new
    menu.add( 'Reports', reports_path )
    menu
  end

end
