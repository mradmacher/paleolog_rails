require 'test_helper'

class SamplesControllerTest < ActionController::TestCase
  setup do
    @well = Well.sham!
    @sample = Sample.sham!( well: @well )
  end

  context 'for guest' do
    should 'refute to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index, well_id: @well.id
      end
    end

    should 'refute to GET show' do
      assert_raise( User::NotAuthorized ) do
        get :show, id: @sample.id
      end
    end

    should 'refute to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @sample.id
      end
    end

    should 'refute to GET new' do
      assert_raise( User::NotAuthorized ) do
        get :new, well_id: @well.id
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @sample.id, sample: @sample.attributes
      end
    end

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, sample: Sample.sham!( :build, well: @well ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @sample.id
      end
    end
  end

  context 'for user not in research' do
    setup do
      @user = User.sham!
      login( @user )
    end

    context 'GET index' do
      should 'return empty result' do
        get :index, format: :json, well_id: @well.to_param
        assert_response :success
        assert assigns( :samples ).empty?
      end
    end

    context 'GET show' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          get :show, id: @sample.id
        end
      end
    end

    context 'GET edit' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          get :edit, id: @sample.id
        end
      end
    end

    context 'GET new' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          get :new, well_id: @well.id
        end
      end
    end

    context 'PUT update' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          put :update, id: @sample.id, sample: @sample.attributes
        end
      end
    end

    context 'POST create' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          post :create, sample: Sample.sham!( :build, well: @well ).attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          assert_no_difference( 'Sample.count' ) do
            delete :destroy, id: @sample.id
          end
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @well.region, manager: false)
      login( @user )
    end

    context 'GET index' do
      should 'be successful' do
        get :index, format: :json, well_id: @well.to_param
        assert_response :success
        assert_equal [@sample], assigns( :samples )
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @sample.to_param
        assert_response :success
        assert_equal @sample, assigns( :sample )
      end

      should 'show proper actions' do
        get :show, :id => @sample.id
        assert_no_link edit_sample_path( @sample )
        assert_no_delete_link sample_path( @sample )
      end
    end

    context 'GET edit' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          get :edit, id: @sample.to_param
        end
      end
    end

    context 'GET new' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          get :new, well_id: @well.id
        end
      end
    end

    context 'PUT update' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          put :update, id: @sample.id, sample: @sample.attributes
        end
      end
    end

    context 'POST create' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          post :create, sample: Sample.sham!( :build, well: @well ).attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          assert_no_difference( 'Sample.count' ) do
            delete :destroy, id: @sample.id
          end
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @well.region, manager: true)
      login( @user )
    end

    context 'GET show' do
      should 'show proper action for sample with occurrences' do
        Occurrence.sham!(sample: @sample, counting: Counting.sham!(region: @well.region))
        get :show, :id => @sample.id
        assert_link edit_sample_path( @sample )
        assert_no_delete_link sample_path( @sample )
      end

      should 'show proper action for sample without sample countings' do
        get :show, :id => @sample.id
        assert_link edit_sample_path( @sample )
        assert_delete_link sample_path( @sample )
      end
    end

    context 'GET edit' do
      should 'be successful' do
        get :edit, id: @sample.to_param
        assert_response :success
        assert_equal @sample, assigns( :sample )

        assert_link sample_path( @sample )
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, well_id: @well.id
        assert_response :success
        assert_equal @well, assigns( :sample ).well

        assert_link well_path( @well )
      end
    end

    context 'PUT update' do
      should 'be successful' do
        put :update, id: @sample.id, sample: @sample.attributes
        assert_redirected_to sample_path( id: @sample.to_param )
      end
    end

    context 'POST create' do
      should 'be successful' do
        sample = Sample.sham!( :build, well: @well )
        assert_difference( 'Sample.count' ) do
          post :create, sample: sample.attributes
        end
        assert_redirected_to sample_path( id: assigns( :sample ).to_param )
      end
    end

    context 'DELETE destroy' do
      should 'be successful' do
        assert_difference( 'Sample.count', -1 ) do
          delete :destroy, id: @sample.id
        end
        assert_redirected_to well_path( id: @well.to_param )
      end
    end
  end

end

