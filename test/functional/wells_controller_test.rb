require 'test_helper'

class WellsControllerTest < ActionController::TestCase
  setup do
    @region = Region.sham!
    @well = Well.sham!( region: @region )
  end

  context 'for guest' do
    should 'refute to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index, region_id: @region.id
      end
    end

    should 'refute to GET show' do
      assert_raise( User::NotAuthorized ) do
        get :show, id: @well.id
      end
    end

    should 'refute to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @well.id
      end
    end

    should 'refute to GET new' do
      assert_raise( User::NotAuthorized ) do
        get :new, region_id: @region.id
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @well.id, well: @well.attributes
      end
    end

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, well: Well.sham!( :build, region: @region ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @well.id
      end
    end
  end

  context 'for user not in research' do
    setup do
      @user = User.sham!
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index, format: :json, region_id: @region.to_param
        assert_response :success
      end

      should 'not assign wells' do
        get :index, format: :json, region_id: @region.to_param
        assert assigns( :wells ).empty?
      end
    end

    context 'GET show' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          get :show, id: @well.id
        end
      end
    end

    context 'GET edit' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          get :edit, id: @well.id
        end
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, region_id: @region.id
        assert_response :success
        assert_equal @region, assigns( :well ).region

        assert_link region_path( @region )
      end
    end

    context 'POST create' do
      should 'be successful' do
        well = Well.sham!( :build, region: @region )
        assert_difference( 'Well.count' ) do
          post :create, well: well.attributes
        end
        assert_redirected_to well_path( id: assigns( :well ).to_param )
      end
    end

    context 'PUT update' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          put :update, id: @well.id, well: @well.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          assert_no_difference( 'Well.count' ) do
            delete :destroy, id: @well.id
          end
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @well.region, manager: false)
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index, format: :json, region_id: @region.to_param
        assert_response :success
      end

      should 'assign wells for user in research' do
        get :index, format: :json, region_id: @region.to_param
        assert_response :success
        assert_equal [@well], assigns( :wells )
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @well.to_param
        assert_response :success
        assert_equal @well, assigns( :well )
      end

      should 'show proper links' do
        get :show, :id => @well.id
        assert_no_link new_well_sample_path( @well )
        assert_no_link edit_well_path( @well )
        assert_no_delete_link well_path( @well )
      end
    end

    context 'GET edit' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          get :edit, id: @well.to_param
        end
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, region_id: @region.id
        assert_response :success
        assert_equal @region, assigns( :well ).region

        assert_link region_path( @region )
      end
    end

    context 'POST create' do
      should 'be successful' do
        well = Well.sham!( :build, region: @region )
        assert_difference( 'Well.count' ) do
          post :create, well: well.attributes
        end
        assert_redirected_to well_path( id: assigns( :well ).to_param )
      end
    end

    context 'PUT update' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          put :update, id: @well.id, well: @well.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'refute access for user in research' do
        assert_raise( User::NotAuthorized ) do
          assert_no_difference( 'Well.count' ) do
            delete :destroy, id: @well.id
          end
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @well.region, manager: true)
      login @user
    end

    context 'GET show' do
      should 'show proper links for well with samples' do
        sample = Sample.sham!( :well => @well )
        get :show, :id => @well.id
        assert_link new_well_sample_path( @well )
        assert_link edit_well_path( @well )
        assert_no_delete_link well_path( @well )
      end

      should 'show proper links for well without samples' do
        get :show, :id => @well.id
        assert_link new_well_sample_path( @well )
        assert_link edit_well_path( @well )
        assert_delete_link well_path( @well )
      end
    end

    context 'GET edit' do
      should 'be successful for manager in research' do
        get :edit, id: @well.to_param
        assert_response :success
        assert_equal @well, assigns( :well )

        assert_link well_path( @well )
      end
    end

    context 'PUT update' do
      should 'be successful for manager in research' do
        put :update, id: @well.id, well: @well.attributes
        assert_redirected_to well_path( id: @well.to_param )
      end
    end

    context 'DELETE destroy' do
      should 'be successful for manager in research' do
        assert_difference( 'Well.count', -1 ) do
          delete :destroy, id: @well.id
        end
        assert_redirected_to region_path( id: @region.to_param )
      end
    end
  end

end

