require 'test_helper'

class RegionsControllerTest < ActionController::TestCase
  setup do
    @region = Region.sham!
  end

  context 'for guest' do
    should 'refute access to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index
      end
    end

    should 'refute access to GET show' do
      assert_raise( User::NotAuthorized ) do
        get :show, id: @region.id
      end
    end

    should 'refute access to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @region.id
      end
    end

    should 'refute access to GET new' do
      assert_raise( User::NotAuthorized ) do 
        get :new
      end
    end

    should 'refute access to PUT update' do
      assert_raise( User::NotAuthorized ) do 
        put :update, id: @region.id, region: @region.attributes 
      end
    end 

    should 'refute access to POST create' do
      assert_raise( User::NotAuthorized ) do 
        post :create, region: Region.sham!( :build ).attributes
      end
    end

    should 'refute access to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do 
        delete :destroy, id: @region.id
      end
    end
  end

  context 'for user' do
    setup do
      @user = User.sham!
      login( @user )
    end

    context 'GET index' do
      should 'be successful' do
        get :index
        assert_response :success
        refute_nil assigns( :regions )

        assert_no_link new_region_path
      end
      
      should 'not show link to create region' do
        get :index
        assert_no_link new_region_path
      end
    end

    context 'GET show' do

      should 'be successful' do
        get :show, id: @region.to_param
        assert_response :success
        assert_equal @region, assigns( :region )
      end

      should 'not show links' do
        get :show, id: @region.to_param
        assert_no_link new_region_well_path( @region )
        assert_no_link edit_region_path( @region.id )
        assert_no_delete_link region_path( @region.id )
      end
    end

    should 'refute access to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @region.id
      end
    end

    should 'refute access to GET new' do
      assert_raise( User::NotAuthorized ) do 
        get :new
      end
    end

    should 'refute access to PUT update' do
      assert_raise( User::NotAuthorized ) do 
        put :update, id: @region.id, region: @region.attributes 
      end
    end 

    should 'refute access to POST create' do
      assert_raise( User::NotAuthorized ) do 
        post :create, region: Region.sham!( :build ).attributes
      end
    end

    should 'refute access to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do 
        delete :destroy, id: @region.id
      end
    end
  end

  context 'for admin' do
    setup do
      @user = User.sham!
      @user.admin = true
      @user.save
      login( @user )
    end

    context 'GET index' do
      should 'be successful' do
        get :index
        assert_response :success
        refute_nil assigns( :regions )
      end

      should 'show link to create region' do
        get :index
        assert_link new_region_path
      end
    end

    context 'GET show' do
      should 'show proper links for region with wells' do
        well = Well.sham!( :region => @region )
        get :show, :id => @region.id
        assert_link new_region_well_path( @region )
        assert_link edit_region_path( @region )
        assert_no_delete_link region_path( @region )
      end

      should 'show proper links for region without wells' do
        get :show, :id => @region.id
        assert_link new_region_well_path( @region )
        assert_link edit_region_path( @region )
        assert_delete_link region_path( @region )
      end

    end

    context 'GET edit' do
      should 'be successful' do
        get :edit, id: @region.to_param
        assert_response :success
        assert_equal @region, assigns( :region )

        assert_link region_path( @region )
      end
    end

    context 'GET new' do 
      should 'be successful' do
        get :new, region_id: @region.id
        assert_response :success

        assert_link regions_path
      end
    end

    context 'PUT update' do
      should 'be successful' do
        put :update, id: @region.id, region: @region.attributes
        assert_redirected_to region_url( id: @region.to_param )
      end 
    end

    context 'POST create' do
      should 'be successful' do
        region = Region.sham!( :build )
        assert_difference( 'Region.count' ) do
          post :create, region: region.attributes
        end
        assert_redirected_to region_url( id: assigns( :region ).to_param )
      end
    end

    context 'DELETE destroy' do
      should 'be successful' do
        assert_difference( 'Region.count', -1 ) do
          delete :destroy, id: @region.id
        end
        assert_redirected_to regions_url
      end
    end
  end
end


