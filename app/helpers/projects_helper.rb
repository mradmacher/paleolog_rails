module ProjectsHelper
	def project_content_menu_for( view )
		Menu.new
	end

	def navigation_for_project( id, name )
		['Project', name, project_path( id )]
	end

end
