module RegionsHelper
	def region_content_menu_for( view )
		Menu.new
	end

	def navigation_for_region( id, name )
		['Region', name, region_path( id )]
	end

end
