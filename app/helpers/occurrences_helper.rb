module OccurrencesHelper
  def button_to_remove( specimen_id, specimen_type, sample_id, counting )
    button_to 'Remove',
      { :action => :remove_specimen, 
        :specimen_id => specimen_id, 
        :sample_id => sample_id, 
        :specimen_type => specimen_type,
        :counting => counting }, 
    :remote => true,
    :onclick => "return confirm('Are you sure?')"
  end

  def button_to_add( specimen_id, specimen_type, sample_id, counting )
    button_to 'Add',
      { :action => :add_specimen, 
        :specimen_id => specimen_id, 
        :sample_id => sample_id, 
        :specimen_type => specimen_type,
        :counting => counting }, 
      :remote => true
    end

  def occurrence_content_menu_for( view )
    menu = Menu.new
    case view
      when 'index'
        menu.add( 'Back', sample_path( @counting.sample_id ) )
      when 'edit'
        menu.add( 'Back', sample_path( @counting.sample_id ) )
    end
    menu
  end

  def occurrence_navigation_for( view )
    menu = Menu.new
    menu.add( 'Sections', sections_path )
    menu.add( @counting.sample.section.name, section_path( @counting.sample.section_id ) )
    menu.add( @counting.sample.name, sample_path( @counting.sample_id ) )
    case view
      when 'edit_specimens'
        menu.add( 'Editing specimens', '' )
      when 'count_specimens'
        menu.add( 'Counting specimens', '' )
    end
    menu
  end
end
