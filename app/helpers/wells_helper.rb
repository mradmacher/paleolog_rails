module WellsHelper
	def well_content_menu_for( view )
		Menu.new
	end

	def navigation_for_well( id, name )
		['Well', name, well_path( id )]
	end
end
