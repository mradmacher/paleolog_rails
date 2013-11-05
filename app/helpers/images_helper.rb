module ImagesHelper
  def resizable_image_tag( image )
    image_tag( image.url( :thumb ), 
        :onclick => "toggle_images(this, '#{image.url( :thumb )}', '#{image.url( :medium )}')" )
  end

  def image_content_menu_for( view )
    Menu.new
  end

  def image_navigation_for( view )
    Menu.new
  end

	def navigation_for_imageable( image )
		['Species', image.specimen.name, specimen_path( image.specimen_id )]
	end

end
