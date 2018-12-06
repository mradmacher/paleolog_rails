require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  setup do
    @project = Project.sham!
    @section = Section.sham!( project: @project )
  end

  context 'for guest' do
    should 'refute to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index, project_id: @project.id
      end
    end

    should 'refute to GET show' do
      assert_raise( User::NotAuthorized ) do
        get :show, id: @section.id
      end
    end

    should 'refute to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @section.id
      end
    end

    should 'refute to GET new' do
      assert_raise( User::NotAuthorized ) do
        get :new, project_id: @project.id
      end
    end

    should 'refute to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @section.id, section: @section.attributes
      end
    end

    should 'refute to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, section: Section.sham!( :build, project: @project ).attributes
      end
    end

    should 'refute to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @section.id
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
        get :index, format: :json, project_id: @project.to_param
        assert_response :success
      end

      should 'not assign sections' do
        get :index, format: :json, project_id: @project.to_param
        assert assigns( :sections ).empty?
      end
    end

    context 'GET show' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          get :show, id: @section.id
        end
      end
    end

    context 'GET edit' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          get :edit, id: @section.id
        end
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, project_id: @project.id
        assert_response :success
        assert_equal @project, assigns( :section ).project

        assert_link project_path( @project )
      end
    end

    context 'POST create' do
      should 'be successful' do
        section = Section.sham!( :build, project: @project )
        assert_difference( 'Section.count' ) do
          post :create, section: section.attributes
        end
        assert_redirected_to section_path( id: assigns( :section ).to_param )
      end
    end

    context 'PUT update' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          put :update, id: @section.id, section: @section.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'not find record' do
        assert_raise( ActiveRecord::RecordNotFound ) do
          assert_no_difference( 'Section.count' ) do
            delete :destroy, id: @section.id
          end
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, project: @section.project, manager: false)
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index, format: :json, project_id: @project.to_param
        assert_response :success
      end

      should 'assign sections for user in research' do
        get :index, format: :json, project_id: @project.to_param
        assert_response :success
        assert_equal [@section], assigns( :sections )
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @section.to_param
        assert_response :success
        assert_equal @section, assigns( :section )
      end

      should 'show proper links' do
        get :show, :id => @section.id
        assert_no_link new_section_sample_path( @section )
        assert_no_link edit_section_path( @section )
        assert_no_delete_link section_path( @section )
      end
    end

    context 'GET edit' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          get :edit, id: @section.to_param
        end
      end
    end

    context 'GET new' do
      should 'be successful' do
        get :new, project_id: @project.id
        assert_response :success
        assert_equal @project, assigns( :section ).project

        assert_link project_path( @project )
      end
    end

    context 'POST create' do
      should 'be successful' do
        section = Section.sham!( :build, project: @project )
        assert_difference( 'Section.count' ) do
          post :create, section: section.attributes
        end
        assert_redirected_to section_path( id: assigns( :section ).to_param )
      end
    end

    context 'PUT update' do
      should 'refute access' do
        assert_raise( User::NotAuthorized ) do
          put :update, id: @section.id, section: @section.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'refute access for user in research' do
        assert_raise( User::NotAuthorized ) do
          assert_no_difference( 'Section.count' ) do
            delete :destroy, id: @section.id
          end
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, project: @section.project, manager: true)
      login @user
    end

    context 'GET show' do
      should 'show proper links for section with samples' do
        sample = Sample.sham!( :section => @section )
        get :show, :id => @section.id
        assert_link new_section_sample_path( @section )
        assert_link edit_section_path( @section )
        assert_no_delete_link section_path( @section )
      end

      should 'show proper links for section without samples' do
        get :show, :id => @section.id
        assert_link new_section_sample_path( @section )
        assert_link edit_section_path( @section )
        assert_delete_link section_path( @section )
      end
    end

    context 'GET edit' do
      should 'be successful for manager in research' do
        get :edit, id: @section.to_param
        assert_response :success
        assert_equal @section, assigns( :section )

        assert_link section_path( @section )
      end
    end

    context 'PUT update' do
      should 'be successful for manager in research' do
        put :update, id: @section.id, section: @section.attributes
        assert_redirected_to section_path( id: @section.to_param )
      end
    end

    context 'DELETE destroy' do
      should 'be successful for manager in research' do
        assert_difference( 'Section.count', -1 ) do
          delete :destroy, id: @section.id
        end
        assert_redirected_to project_path( id: @project.to_param )
      end
    end
  end

end

