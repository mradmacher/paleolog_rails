require 'test_helper' 

class SpecimensControllerTest < ActionController::TestCase

  context 'for guest' do
    should 'refute to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index
      end
    end

    should 'refute to GET show' do
      assert_raise( User::NotAuthorized ) do
        get :show, id: Specimen.sham!.id
      end
    end

    should 'refute to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: Specimen.sham!.id
      end
    end

    should 'refute to GET new' do
      assert_raise( User::NotAuthorized ) do
        get :new
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        specimen = Specimen.sham!
        put :update, id: specimen.id, specimen: specimen.attributes
      end
    end 

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, specimen: Specimen.sham!( :build ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: Specimen.sham!.id
      end
    end
  end

  context 'for user' do
    setup do
      @user = User.sham!
      @specimen = Specimen.sham!
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index
        assert_response :success
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @specimen.id 
        assert_response :success
      end

      should 'not allow to edit features' do
        feature = Feature.sham!
        get :show, id: feature.specimen_id 
        assert_select 'form[action=?]', feature_path( feature ), 0
      end

      should 'not allow to create features' do
        field = Field.sham!( group: @specimen.group )
        get :show, id: @specimen.id 
        assert_select 'form[action=?]', features_path, 0
      end
    end

    should 'refute to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @specimen.id
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @specimen.id, specimen: @specimen.attributes
      end
    end 

    should 'refute to POST create' do
      specimen = Specimen.sham!( :build )
      assert_raise( User::NotAuthorized ) do
        assert_no_difference( 'Specimen.count' ) do
          post :create, specimen: specimen.attributes
        end
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        assert_no_difference( 'Specimen.count' ) do
          delete :destroy, id: @specimen.id
        end
      end
    end

  end

  context 'for admin' do
    setup do
      @user = User.sham!
      @user.admin = true
      @user.save
      @specimen = Specimen.sham!
      login @user
    end

    should 'be successful with GET index' do
      get :index
      assert_response :success
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @specimen.id
        assert_response :success
      end

      should 'allow to edit features' do
        feature = Feature.sham!
        get :show, id: feature.specimen_id 
        assert_select 'form[action=?]', feature_path( feature )
      end

      should 'allow to create features' do
        field = Field.sham!( group: @specimen.group )
        get :show, id: @specimen.id 
        assert_select 'form[action=?]', features_path
      end

      should 'allow to destroy feature' do

      end
    end

    context 'GET edit' do
      should 'be successful' do
        get :edit, id: @specimen.id
        assert_response :success
      end
    end

    context 'PUT update' do
      should 'be successful' do
        put :update, id: @specimen.id, specimen: @specimen.attributes
        assert_redirected_to specimen_path( id: @specimen.to_param )
      end 
    end

    context 'on POST create' do
      context 'within account' do
        setup { @specimen = Specimen.sham!( :build ) }

        should 'be successful' do
          assert_difference( 'Specimen.count' ) do
            post :create, specimen: @specimen.attributes
          end
          assert_redirected_to specimen_path( id: assigns( :specimen ).id )
        end
      end

    end

    context 'on DELETE destroy' do
      should 'be successful' do
        assert_difference( 'Specimen.count', -1 ) do
          delete :destroy, id: @specimen.id
        end
        assert_redirected_to specimens_path
      end
    end

  end

end

