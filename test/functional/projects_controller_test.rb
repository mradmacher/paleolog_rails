require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = Project.sham!
  end

  context 'for guest' do
    should 'refute access to GET index' do
      assert_raise( User::NotAuthorized ) do
        get :index
      end
    end

    should 'refute access to GET show' do
      assert_raise( User::NotAuthorized ) do
        get :show, id: @project.id
      end
    end

    should 'refute access to GET edit' do
      assert_raise( User::NotAuthorized ) do
        get :edit, id: @project.id
      end
    end

    should 'refute access to GET new' do
      assert_raise( User::NotAuthorized ) do
        get :new
      end
    end

    should 'refute access to PUT update' do
      assert_raise( User::NotAuthorized ) do
        put :update, id: @project.id, project: @project.attributes
      end
    end

    should 'refute access to POST create' do
      assert_raise( User::NotAuthorized ) do
        post :create, project: Project.sham!( :build ).attributes
      end
    end

    should 'refute access to DELETE destroy' do
      assert_raise( User::NotAuthorized ) do
        delete :destroy, id: @project.id
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

      should 'not assign projects' do
        get :index
        assert assigns(:projects).empty?
      end
    end

    context 'GET show' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          get :show, id: @project.id
        end
      end
    end

    context 'GET edit' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          get :edit, id: @project.id
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
        project = Project.sham!(:build)
        assert_difference('Project.count') do
          post :create, project: project.attributes
        end
        assert_redirected_to project_path(id: assigns(:project).to_param)
      end
    end

    context 'PUT update' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          put :update, id: @project.id, project: @project.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'not find record' do
        assert_raise(ActiveRecord::RecordNotFound) do
          assert_no_difference('Project.count') do
            delete :destroy, id: @project.id
          end
        end
      end
    end
  end

  context 'for user in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, project: @project, manager: false)
      login @user
    end

    context 'GET index' do
      should 'be successful' do
        get :index
        assert_response :success
      end

      should 'assign projects for user in research' do
        get :index
        assert_response :success
        assert_equal [@project], assigns(:projects)
      end
    end

    context 'GET show' do
      should 'be successful' do
        get :show, id: @project.to_param
        assert_response :success
        assert_equal @project, assigns(:project)
      end

      should 'show proper links' do
        get :show, :id => @project.id
        assert_no_link new_project_section_path(@project)
        assert_no_link edit_project_path(@project)
        assert_no_delete_link project_path(@project)
      end
    end

    context 'GET edit' do
      should 'refute access' do
        assert_raise(User::NotAuthorized) do
          get :edit, id: @project.to_param
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
        project = Project.sham!(:build)
        assert_difference('Project.count') do
          post :create, project: project.attributes
        end
        assert_redirected_to project_path(id: assigns(:project).to_param)
      end
    end

    context 'PUT update' do
      should 'refute access' do
        assert_raise(User::NotAuthorized) do
          put :update, id: @project.id, project: @project.attributes
        end
      end
    end

    context 'DELETE destroy' do
      should 'refute access for user in research' do
        assert_raise(User::NotAuthorized) do
          assert_no_difference('Project.count') do
            delete :destroy, id: @project.id
          end
        end
      end
    end
  end

  context 'for manager in research' do
    setup do
      @user = User.sham!
      ResearchParticipation.sham!(user: @user, project: @project, manager: true)
      login @user
    end

    context 'GET show' do
      should 'show proper links' do
        get :show, id: @project.id
        assert_link new_project_section_path(@project)
        assert_link edit_project_path(@project)
      end

      should 'not show delete link for project with sections' do
        section = Section.sham!(project: @project)
        get :show, id: @project.id
        assert_no_delete_link project_path(@project)
      end

      should 'show delete link for project without sections' do
        get :show, id: @project.id
        assert_delete_link project_path(@project)
      end
    end

    context 'GET edit' do
      should 'be successful for manager in research' do
        get :edit, id: @project.to_param
        assert_response :success
        assert_equal @project, assigns(:project)

        assert_link project_path(@project)
      end
    end

    context 'PUT update' do
      should 'be successful for manager in research' do
        put :update, id: @project.id, project: @project.attributes
        assert_redirected_to project_path(id: @project.to_param)
      end
    end

    context 'DELETE destroy' do
      should 'be successful for manager in research' do
        assert_difference('Project.count', -1) do
          delete :destroy, id: @project.id
        end
        assert_redirected_to projects_path
      end
    end
  end
end
