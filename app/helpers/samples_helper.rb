module SamplesHelper
	def sample_content_menu_for( view )
		Menu.new
	end

	def navigation_for_sample( id, name )
		['Sample', name, sample_path( id )]
	end
end
