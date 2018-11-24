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

  context 'for user not in research' do
    setup do
      @user = User.sham!
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index
        assert_response :success
      end

      should 'not assign regions' do
        get :index
        assert assigns(:regions).empty?
      end
    end

    context 'GET show' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          get :show, id: @region.id
        end
      end
    end

    context 'GET edit' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          get :edit, id: @region.id
        end
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new
        assert_response :success
      end
    end

    context 'POST create' do
      should 'be successful' do
        region = Region.sham!(:build)
        assert_difference('Region.count') do
          post :create, region: region.attributes
        end
        assert_redirected_to region_path(id: assigns(:region).to_param)
      end
    end

    context 'PUT update' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          put :update, id: @region.id, region: @region.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          assert_no_difference('Region.count') do
            delete :destroy, id: @region.id
          end
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @region, manager: false)
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index
        assert_response :success
      end

      should 'assign regions for user in research' do
        get :index
        assert_response :success
        assert_equal [@region], assigns(:regions)
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @region.to_param
        assert_response :success
        assert_equal @region, assigns(:region)
      end

      should 'show proper links' do
        get :show, :id => @region.id
        assert_no_link new_region_well_path(@region)
        assert_no_link edit_region_path(@region)
        assert_no_delete_link region_path(@region)
      end
    end

    context 'GET edit' do
      should 'refute access' do
        assert_raise(User::NotAuthorized) do
          get :edit, id: @region.to_param
        end
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new
        assert_response :success
      end
    end

    context 'POST create' do
      should 'be successful' do
        region = Region.sham!(:build)
        assert_difference('Region.count') do
          post :create, region: region.attributes
        end
        assert_redirected_to region_path(id: assigns(:region).to_param)
      end
    end

    context 'PUT update' do
      should 'refute access' do
        assert_raise(User::NotAuthorized) do
          put :update, id: @region.id, region: @region.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'refute access for user in research' do
        assert_raise(User::NotAuthorized) do
          assert_no_difference('Region.count') do
            delete :destroy, id: @region.id
          end
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @region, manager: true)
      login @user
    end

    context 'GET show' do
      should 'show proper links' do
        get :show, id: @region.id
        assert_link new_region_well_path(@region)
        assert_link edit_region_path(@region)
      end

      should 'not show delete link for region with wells' do
        well = Well.sham!(region: @region)
        get :show, id: @region.id
        assert_no_delete_link region_path(@region)
      end

      should 'show delete link for region without wells' do
        get :show, id: @region.id
        assert_delete_link region_path(@region)
      end
    end

    context 'GET edit' do
      should 'be successful for manager in research' do
        get :edit, id: @region.to_param
        assert_response :success
        assert_equal @region, assigns(:region)

        assert_link region_path(@region)
      end
    end

    context 'PUT update' do
      should 'be successful for manager in research' do
        put :update, id: @region.id, region: @region.attributes
        assert_redirected_to region_path(id: @region.to_param)
      end
    end

    context 'DELETE destroy' do
      should 'be successful for manager in research' do
        assert_difference('Region.count', -1) do
          delete :destroy, id: @region.id
        end
        assert_redirected_to regions_path
      end
    end
  end
end
