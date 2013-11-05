module CountingsHelper
  def counting_content_menu_for( view )
      Menu.new
  end

	def navigation_for_counting( id, name )
		['Counting', name, counting_path( id )]
	end
end
