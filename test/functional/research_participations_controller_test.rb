require 'test_helper'

class ResearchParticipationsControllerTest < ActionController::TestCase
  setup do
    @region = Region.sham!
    @other_user = User.sham!
  end

  context 'for guest' do
    should 'refute to GET show' do
      assert_raises(User::NotAuthorized) do
        get :show, id: ResearchParticipation.sham!(region: @region, user: @other_user)
      end
    end

    should 'refute to GET new' do
      assert_raises(User::NotAuthorized) do
        get :new, region_id: @region.id
      end
    end

    should 'refute to POST create ' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!(:build, region: @region, user: @other_user).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference('ResearchParticipation.count') do
          delete :destroy, id: ResearchParticipation.sham!(region: @region, user: @other_user).id
        end
      end
    end
  end

  context 'for user' do
    setup do
      @user = User.sham!
      login @user
    end

    should 'refute to GET show' do
      assert_raises(User::NotAuthorized) do
        get :show, id: ResearchParticipation.sham!(region: @region, user: @other_user)
      end
    end

    should 'refute to GET new' do
      assert_raises(User::NotAuthorized) do
        get :new, region_id: @region.id
      end
    end

    should 'refute to POST create' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!(:build, region: @region, user: @user).attributes
        end
      end

      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!(:build, region: @region, user: @other_user).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          delete :destroy, id: ResearchParticipation.sham!(region: @region, user: @other_user).id
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      @research_participation = ResearchParticipation.sham!(region: @region, user: @user, manager: false)
      login @user
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @research_participation.id
        assert_response :success
      end
    end

    should 'refute to GET new' do
      assert_raises(User::NotAuthorized) do
        get :new, region_id: @region.id
      end
    end

    should 'refute to POST create' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!(:build, region: @region, user: @other_user).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      participation = ResearchParticipation.sham!(region: @region, user: @other_user)
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          delete :destroy, id: participation.id
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      @research_participation = ResearchParticipation.sham!(region: @region, user: @user, manager: true)
      login @user
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @research_participation.id
        assert_response :success
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, region_id: @region.id
        assert_response :success
      end
    end

    context 'POST create' do
      should 'be successful' do
        participation = ResearchParticipation.sham!(:build, region: @region, user: User.sham! )
        assert_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: participation.attributes
        end
        assert_redirected_to region_url(id: @region.id)
      end
    end

    context 'DELETE destroy' do
      should 'be successful' do
        participation = ResearchParticipation.sham!(region: @region, user: @other_user)
        assert_difference( 'ResearchParticipation.count', -1 ) do
          delete :destroy, id: participation.id
        end
        assert_redirected_to region_path(id: @region.id)
      end
    end
  end
end
