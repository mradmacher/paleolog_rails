require 'test_helper'

class CountingsControllerTest < ActionController::TestCase
  setup do
    @well = Well.sham!
    @counting = Counting.sham!( well: @well )
  end

  context 'for guest' do
    should 'refute access to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index, well_id: @well.id
      end
    end

    should 'refute to GET show' do
      assert_raise( User::NotAuthorized ) do 
        get :show, id: @counting.id 
      end
    end

    should 'refute to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @counting.id
      end
    end
    
    should 'refute to GET new' do
      assert_raise( User::NotAuthorized ) do 
        get :new, well_id: @well.id 
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do 
        put :update, id: @counting.id, counting: @counting.attributes 
      end
    end 

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do 
        post :create, counting: Counting.sham!( :build, well: @well ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do 
        delete :destroy, id: @counting.id
      end
    end
  end

  context 'for user not in research' do
    setup do
      @user = User.sham!
      login( @user )
    end

    context 'GET index' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do 
          get :index, format: :json, well_id: @well.to_param
        end
      end
    end

    context 'GET show' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do 
          get :show, id: @counting.id
        end
      end
    end

    context 'GET edit' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do 
          get :edit, id: @counting.id
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
          put :update, id: @counting.id, counting: @counting.attributes
        end
      end 
    end

    context 'POST create' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do 
          post :create, counting: Counting.sham!( :build, well: @well ).attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do 
          assert_no_difference( 'Counting.count' ) do
            delete :destroy, id: @counting.id
          end
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!( user: @user, well: @well, manager: false )
      login( @user )
    end

    context 'GET index' do
      should 'be successful' do
        get :index, format: :json, well_id: @well.to_param
        assert_response :success
        assert_equal [@counting], assigns( :countings )
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @counting.to_param
        assert_response :success
        assert_equal @counting, assigns( :counting )
      end

      should 'show proper actions' do
        get :show, :id => @counting.id

        assert_no_link edit_counting_path( @counting )
        assert_no_delete_link counting_path( @counting )
      end
    end

    context 'GET edit' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do 
          get :edit, id: @counting.to_param
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
          put :update, id: @counting.id, counting: @counting.attributes
        end
      end 
    end

    context 'POST create' do
      should 'refute access for user in research' do
        assert_raise( User::NotAuthorized ) do 
          post :create, counting: Counting.sham!( :build, well: @well ).attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'refute access for user in research' do
        assert_raise( User::NotAuthorized ) do 
          assert_no_difference( 'Counting.count' ) do
            delete :destroy, id: @counting.id
          end
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!( user: @user, well: @well, manager: true )
      login( @user )
    end

    context 'GET show' do
      should 'show proper actions for counting without sample countings' do
        get :show, :id => @counting.id

        assert_link edit_counting_path( @counting )
        assert_delete_link counting_path( @counting )
      end

      should 'show proper actions for counting with occurrences' do
        Occurrence.sham!( :sample => Sample.sham!( well: @well ), :counting => @counting )
        get :show, :id => @counting.id
        assert_link edit_counting_path( @counting )
        assert_no_delete_link counting_path( @counting )
      end
    end

    context 'GET edit' do
      should 'be successful' do
        get :edit, id: @counting.to_param
        assert_response :success
        assert_equal @counting, assigns( :counting )

        assert_link counting_path( @counting )
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, well_id: @well.id
        assert_response :success
        assert_equal @well, assigns( :counting ).well

        assert_link well_path( @well )
      end
    end

    context 'PUT update' do
      should 'be successful' do
        put :update, id: @counting.id, counting: @counting.attributes
        assert_redirected_to counting_path( id: @counting.to_param )
      end 
    end

    context 'POST create' do
      should 'be successful' do
        counting = Counting.sham!( :build, well: @well )
        assert_difference( 'Counting.count' ) do
          post :create, counting: counting.attributes
        end
        assert_redirected_to counting_path( id: assigns( :counting ).to_param )
      end
    end

    context 'DELETE destroy' do
      should 'be successful' do
        assert_difference( 'Counting.count', -1 ) do
          delete :destroy, id: @counting.id
        end
        assert_redirected_to well_path( id: @well.to_param )
      end
    end
  end
end

