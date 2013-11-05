require 'test_helper'

class ResearchParticipationsControllerTest < ActionController::TestCase
  setup do
    @well = Well.sham!
    @other_user = User.sham!
  end

  context 'for guest' do
    should 'refute to GET index' do
      assert_raises( User::NotAuthorized ) do
        get :index, well_id: @well.id
      end
    end

    should 'refute to POST create ' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!( :build, well: @well, user: @other_user ).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          delete :destroy, id: ResearchParticipation.sham!( well: @well, user: @other_user ).id
        end
      end
    end
  end

  context 'for user' do
    setup do
      @user = User.sham!
      login @user
    end

    should 'refute to GET index' do
      assert_raises( User::NotAuthorized ) do
        get :index, well_id: @well.id
      end
    end

    should 'refute to POST create' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!( :build, well: @well, user: @user ).attributes
        end
      end

      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!( :build, well: @well, user: @other_user ).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          delete :destroy, id: ResearchParticipation.sham!( well: @well, user: @other_user ).id
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!( well: @well, user: @user, manager: false )
      login @user
    end
    
    context 'GET index' do
      should 'be successful' do
        get :index, well_id: @well.id
        assert_response :success
      end
    end

    should 'refute to POST create' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!( :build, well: @well, user: @other_user ).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      participation = ResearchParticipation.sham!( well: @well, user: @other_user )
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
      ResearchParticipation.sham!( well: @well, user: @user, manager: true )
      login @user
    end

    context 'POST create' do
      should 'be successful' do
        participation = ResearchParticipation.sham!( :build, well: @well, user: User.sham! )
        assert_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: participation.attributes
        end
        assert_redirected_to well_research_participations_url( well_id: @well.id )
      end
    end

    context 'DELETE destroy' do 
      should 'be successful' do
        participation = ResearchParticipation.sham!( well: @well, user: @other_user )
        assert_difference( 'ResearchParticipation.count', -1 ) do
          delete :destroy, id: participation.id
        end
        assert_redirected_to well_research_participations_path( well_id: @well.id )
      end
    end
  end

  
  context 'for admin' do
    setup do
      @user = User.sham!
      @user.admin = true
      @user.save
      login @user
    end

    should 'refute to GET index' do
      assert_raises( User::NotAuthorized ) do
        get :index, well_id: @well.id
      end
    end

    should 'refute to POST create' do
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!( :build, well: @well, user: @user ).attributes
        end
      end

      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          post :create, research_participation: ResearchParticipation.sham!( :build, well: @well, user: @other_user ).attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      participation = ResearchParticipation.sham!( well: @well, user: @other_user )
      assert_raises( User::NotAuthorized ) do
        assert_no_difference( 'ResearchParticipation.count' ) do
          delete :destroy, id: participation.id
        end
      end
    end
  end
  
end

