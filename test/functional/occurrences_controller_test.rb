require 'test_helper'

class OccurrencesControllerTest < ActionController::TestCase
  setup do
    @region = Region.sham!
    @section = Section.sham!(region: @region)
    @counting = Counting.sham!(region: @region)
    @sample = Sample.sham!(section: @section)
    @specimen = Specimen.sham!
    @occurrence = Occurrence.sham!(sample: @sample, counting: @counting, specimen: @specimen)
  end

  context 'for guest' do
    should 'refute to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index, sample_id: @sample.id, counting_id: @counting.id
      end
    end

    should 'refute to GET count' do
      assert_raise( User::NotAuthorized ) do
        get :count, sample_id: @sample.id, counting_id: @counting.id
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @occurrence.id, occurrence: @occurrence.attributes
      end
    end

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, occurrence: Occurrence.sham!( :build, sample: @sample, counting: @counting, specimen: @specimen ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @occurrence.id
      end
    end

    should 'refute to GET exchange' do
      occ = Occurrence.sham!( sample: @sample, counting: @counting, specimen: Specimen.sham! )
      assert_raise( User::NotAuthorized ) do
        get :exchange, :format => :json, id1: @occurrence.id, id2: occ.id
      end
    end

    should 'refute to GET increase_quantity' do
      assert_raise( User::NotAuthorized ) do
        get :increase_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET decrease_quantity' do
      assert_raise( User::NotAuthorized ) do
        get :decrease_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET set_uncertain' do
      assert_raise( User::NotAuthorized ) do
        get :set_uncertain, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET set_status' do
      assert_raise( User::NotAuthorized ) do
        get :set_status, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET set_quantity' do
      assert_raise( User::NotAuthorized ) do
        get :set_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET available' do
      assert_raise( User::NotAuthorized ) do
        get :available, :format => :json, sample_id: @sample.id, counting_id: @counting.id
      end
    end
  end

  context 'for user not in research' do
    setup do
      @user = User.sham!
      login( @user )
    end

    should 'not find record for GET index' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :index, sample_id: @sample.id, counting_id: @counting.id
      end
    end

    should 'not find record for GET count' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :count, sample_id: @sample.id, counting_id: @counting.id
      end
    end

    should 'not find record for GET available' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :available, :format => :json, sample_id: @sample.id, counting_id: @counting.id
      end
    end

    should 'not find record for PUT update' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        put :update, id: @occurrence.id, occurrence: @occurrence.attributes
      end
    end

    should 'not find record for DELETE destroy' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        assert_no_difference( 'Occurrence.count' ) do
          delete :destroy, id: @occurrence.id
        end
      end
    end

    should 'not find record for GET exchange' do
      occ = Occurrence.sham!( sample: @sample, counting: @counting, specimen: Specimen.sham! )
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :exchange, :format => :json, id1: @occurrence.id, id2: occ.id
      end
    end

    should 'not find record for GET increase_quantity' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :increase_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'not find record for GET set_uncertain' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :set_uncertain, :format => :json, id: @occurrence.id
      end
    end

    should 'not find record for GET decrease_quantity' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :decrease_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'not find record for GET set_quantity' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :set_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'not find record for GET set_status' do
      assert_raise( ActiveRecord::RecordNotFound ) do
        get :set_status, :format => :json, id: @occurrence.id
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @section.region, manager: false)
      login( @user )
    end

    should 'successfully GET index' do
      get :index, sample_id: @sample.id, counting_id: @counting.id
      assert_response :success
    end

    should 'refute to GET count' do
      assert_raise( User::NotAuthorized ) do
        get :count, sample_id: @sample.id, counting_id: @counting.id
      end
    end

    should 'successfully GET available' do
      get :available, :format => :json, sample_id: @sample.id, counting_id: @counting.id
      assert_response :success
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @occurrence.id, occurrence: @occurrence.attributes
      end
    end

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, occurrence: Occurrence.sham!( :build, sample: @sample, counting: @counting, specimen: @specimen ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        assert_no_difference( 'Occurrence.count' ) do
          delete :destroy, id: @occurrence.id
        end
      end
    end

    should 'refute to GET exchange' do
      occ = Occurrence.sham!( sample: @sample, counting: @counting )
      assert_raise( User::NotAuthorized ) do
        get :exchange, :format => :json, id1: @occurrence.id, id2: occ.id
      end
    end

    should 'refute to GET increase_quantity' do
      assert_raise( User::NotAuthorized ) do
        get :increase_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET decrease_quantity' do
      assert_raise( User::NotAuthorized ) do
        get :decrease_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET set_quantity' do
      assert_raise( User::NotAuthorized ) do
        get :set_quantity, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET set_status' do
      assert_raise( User::NotAuthorized ) do
        get :set_status, :format => :json, id: @occurrence.id
      end
    end

    should 'refute to GET set_uncertain' do
      assert_raise( User::NotAuthorized ) do
        get :set_uncertain, :format => :json, id: @occurrence.id
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, region: @section.region, manager: true)
      login( @user )
    end

    context 'GET index' do
      should 'be successful' do
        get :index, sample_id: @sample.id, counting_id: @counting.id
        assert_response :success
      end
    end

    context 'GET count' do
      should 'be successful' do
        get :count, sample_id: @sample.id, counting_id: @counting.id
        assert_response :success
      end
    end

    context 'PUT update' do
      should 'be successful' do
        put :update, id: @occurrence.id, occurrence: @occurrence.attributes
        #assert_redirected_to occurrence_sample_counting_path( subdomain: @account.subdomain, id: @occurrence.to_param )
      end
    end

    context 'POST create' do
      should 'be successful' do
        occurrence = Occurrence.sham!( :build, sample: @sample, counting: @counting )
        assert_difference( 'Occurrence.count' ) do
          post :create, occurrence: occurrence.attributes
        end
        assert_redirected_to edit_counting_sample_occurrences_url( sample_id: @sample.id, counting_id: @counting.id )
      end
    end

    context 'DELETE destroy' do
      should 'be successful' do
        assert_difference( 'Occurrence.count', -1 ) do
          delete :destroy, id: @occurrence.id
        end
        assert_redirected_to edit_counting_sample_occurrences_url( sample_id: @sample.id, counting_id: @counting.id )
      end
    end

    context 'GET available' do
      should 'be successful' do
        get :available, :format => :json, sample_id: @sample.id, counting_id: @counting.id
        assert_response :success
      end
    end

    context 'GET exchange' do
      should 'be successful' do
        occ = Occurrence.sham!( sample: @sample, counting: @counting, specimen: Specimen.sham! )
        get :exchange, :format => :json, id1: @occurrence.id, id2: occ.id
        assert_response :success
      end
    end

    context 'GET increase_quantity' do
      should 'be successful' do
        get :increase_quantity, :format => :json, id: @occurrence.id
        assert_response :success
      end
    end

    context 'GET decrease_quantity' do
      should 'be successful' do
        get :decrease_quantity, :format => :json, id: @occurrence.id
        assert_response :success
      end
    end

    context 'GET set_quantity' do
      should 'be successful' do
        get :set_quantity, :format => :json, id: @occurrence.id
        assert_response :success
      end
    end

    context 'GET set_status' do
      should 'be successful' do
        get :set_status, :format => :json, id: @occurrence.id
        assert_response :success
      end
    end

    context 'GET set_uncertain' do
      should 'be successful' do
        get :set_uncertain, :format => :json, id: @occurrence.id
        assert_response :success
      end
    end
  end
end
