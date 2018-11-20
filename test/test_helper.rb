ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shams'

module I18n
	def self.raise_missing_translation( *args )
		puts args.first
		puts args.first.class
		raise args.first.to_exception
	end
end
I18n.exception_handler = :raise_missing_translation

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
	#fixtures :all

	def user_with_privs( privs )
		role = roles( :default )
		role.privileges.clear
		privs.each { |p| role.privileges << privileges( p ) }
		users( :default )
	end

	def user_without_privs( privs )
		all = [:viewing, :editing, :commenting, :downloading, :uploading]
		user_with_privs( all - privs )
	end

	def session_with( privs )
		{:user_id => user_with_privs( privs ).id}
	end

	def session_without( privs )
		{:user_id => user_without_privs( privs ).id}
	end

  def login_as( user )
		@request.session[:user_id] = user ? user.id : nil
  end
  alias :login :login_as

  def with_subdomain( subdomain )
    @request.host = "#{subdomain}.#{@request.host}"
  end

	def assert_link( path, text = nil )
    if text.nil?
      assert_select "a[href='#{path}']"
    else
      assert_select "a[href='#{path}']", {:text => text}
    end
	end

	def assert_no_link(path)
		assert_select "a[href='#{path}']", false
	end

	def assert_delete_link( path, text = nil )
    if text.nil?
      assert_select "a[href='#{path}'][data-method=delete]"
    else
      assert_select "a[href=#{path}][data-method=delete]", text
    end
	end

	def assert_no_delete_link(path)
		assert_select "a[href='#{path}'][data-method=delete]", false
	end

	def assert_field( name, value )
		assert_select 'dt', name do
			assert_select 'dt+dd', value
		end
	end
	def assert_complex_field( name )
		assert_select 'dt', name do
			assert_select 'dt+dd' do
				yield
			end
		end
	end

	def assert_title( text )
		assert_select 'title', {:text => text}
	end
	def assert_actions
		assert_select '#actions' do
			yield
		end
	end

	def assert_navigation
		assert_select 'div#navigation' do
			yield
		end
	end
	def assert_nav_item( path, header, text )
		assert_select 'th', header
		assert_select 'td a[href=?]', path, text
	end
	def assert_nav_cur_item( path, text )
		assert_select 'td a[href=?]', path, false
		assert_select 'span.navigation_item', text
	end

	def assert_heading( heading )
		assert_select '#heading h1', heading
	end

	def assert_title( title )
		assert_select 'title', "Microhelp - #{title}"
	end

	def assert_access_denied( privs )
		yield Hash.new
		assert_redirected_to login_url
		privs.each do |p|
			yield session_without( [p] )
			assert_redirected_to root_url
		end
	end
###############################################################################
	def resource_navigation_test( action, resource )
		nav = {}
		foreign_id = case resource.class.to_s
			when 'Region'
				nav[:region] = {:id => resource.id, :name => resource.name}
				:region_id
			when 'Well'
				nav[:region] = {:id => resource.region.id, :name => resource.region.name}
				nav[:well] = {:id => resource.id, :name => resource.name}
				:well_id
			when 'Sample'
				nav[:region] = {:id => resource.well.region.id, :name => resource.well.region.name}
				nav[:well] = {:id => resource.well.id, :name => resource.well.name}
				nav[:sample] = {:id => resource.id, :name => resource.name}
				:sample_id
			when 'Counting'
				nav[:region] = {:id => resource.sample.well.region.id, :name => resource.sample.well.region.name}
				nav[:well] = {:id => resource.sample.well.id, :name => resource.sample.well.name}
				nav[:sample] = {:id => resource.sample.id, :name => resource.sample.name}
				nav[:counting] = {:id => resource.id, :name => resource.name}
				:counting_id
			else
				nil
			end
		ref = if [:show, :edit].include? action then
			{:id => resource.id}
		elsif [:new, :index].include? action then
			if foreign_id then {foreign_id => resource.id} else nil end
		else
			nil
		end
		get action, ref, session_with( [:viewing, :editing] )
		assert_response :success
		if !nav.empty?
			assert_navigation do
				if nav.has_key? :region
					assert_nav_item region_path( nav[:region][:id] ), 'Region', nav[:region][:name]
				end
				if nav.has_key? :well
					assert_nav_item well_path( nav[:well][:id] ), 'Well', nav[:well][:name]
				end
				if nav.has_key? :sample
					assert_nav_item sample_path( nav[:sample][:id] ), 'Sample', nav[:sample][:name]
				end
				if nav.has_key? :counting
					assert_nav_item counting_path( nav[:counting][:id] ), 'Counting', nav[:counging][:name]
				end
			end
		end
		if nav.has_key? :region
			assert_title nav[:region][:name]
		else
			assert_title 'Regions'
		end
		heading = if action == :new then
								case resource.class.to_s
								when 'NilClass'
									'New region'
								when 'Region'
									'New well'
								when 'Well'
									'New sample'
								when 'Sample'
									'New counting'
								end
							elsif action == :edit then "Editing #{resource.class.to_s.downcase}"
							else resource.class.to_s.capitalize end

		assert_heading heading
	end

end
