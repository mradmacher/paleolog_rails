require 'menu'

module ApplicationHelper
  def bracketize( item )
    "[#{item}]"
  end

	def render_navigation items
		render :partial => 'layouts/navigation', :locals => { :items => items } 
	end

	def render_title title
		render :partial => 'layouts/title', :locals => { :title => title } 
	end

	def render_heading heading
		render :partial => 'layouts/heading', :locals => { :heading => heading } 
	end

	def render_actions items
		render :partial => 'layouts/actions', :locals => { :items => items }
	end

  def content_menu_for( controller, action ) 
    menu = case controller
      when 'specimens'
        specimen_content_menu_for action
      when 'projects'
        project_content_menu_for action
      when 'sections'
        section_content_menu_for action
      when 'images'
        image_content_menu_for action
      when 'samples'
        sample_content_menu_for action
      when 'comments'
        comment_content_menu_for action
      when 'attachements'
        attachement_content_menu_for action
      when 'countings'
        counting_content_menu_for action
      when 'occurrences'
        occurrence_content_menu_for action
      when 'users'
        user_content_menu_for action
      when 'roles'
        role_content_menu_for action
      when 'reports'
        report_content_menu_for action
      else
        Menu.new
    end
  end

  def navigation_for( controller, action )
    menu = case controller
      when 'site'
        site_navigation_for action
      when 'specimens'
        specimen_navigation_for action
      when 'projects'
        project_navigation_for action
      when 'sections'
        section_navigation_for action
      when 'images'
        image_navigation_for action
      when 'samples'
        sample_navigation_for action
      when 'comments'
        comment_navigation_for action
      when 'attachements'
        attachement_navigation_for action
      when 'countings'
        counting_navigation_for action
      when 'occurrences'
        occurrence_navigation_for action
      when 'users'
        user_navigation_for action
      when 'roles'
        role_navigation_for action
      when 'reports'
        report_navigation_for action
      else
        Menu.new
    end
  end

end

