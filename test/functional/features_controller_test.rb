require 'test_helper' 

class FeaturesControllerTest < ActionController::TestCase
  setup do
    @specimen = Specimen.sham!
    @field = Field.sham!( group: @specimen.group )
    @choice = Choice.sham!( field: @field )
    @feature = Feature.sham!( specimen: @specimen, choice: @choice )
  end

  context 'for guest' do
    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @feature.id, specimen: @feature.attributes
      end
    end 

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, feature: @feature.attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @feature.id
      end
    end
  end

  context 'for user' do
    setup do
      @user = User.sham!
      login @user
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @feature.id, feature: @feature.attributes
      end
    end 

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, feature: @feature.attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @feature.id
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

    context 'PUT update' do
      should 'be successful' do
        put :update, id: @feature.id, feature: @feature.attributes
        assert_redirected_to specimen_path( id: @feature.specimen.to_param )
      end 
    end

    context 'POST create' do
      should 'be successful' do
        choice = Choice.sham!( field: Field.sham!( group: @specimen.group ) )
        assert_difference( 'Feature.count' ) do
          post :create, feature: Feature.sham!( :build, specimen: @specimen, choice: choice ).attributes
        end
        assert_redirected_to specimen_path( id: @specimen.id )
      end
    end

    context 'on DELETE destroy' do
      should 'be successful' do
        assert_difference( 'Feature.count', -1 ) do
          delete :destroy, id: @feature.id
        end
        assert_redirected_to specimen_path( id: @specimen.id )
      end
    end
  end

end

