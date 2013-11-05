module SpecimensHelper
  def specimen_content_menu_for( view )
    Menu.new
  end

  def specimen_navigation_for( view )
    Menu.new
  end

	def navigation_for_species( id, name )
		['Species', name, specimen_path( id )]
	end

end
