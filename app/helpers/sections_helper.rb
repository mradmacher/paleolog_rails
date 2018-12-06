module SectionsHelper
	def section_content_menu_for( view )
		Menu.new
	end

	def navigation_for_section( id, name )
		['Section', name, section_path( id )]
	end
end
