require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def test_if_sham_builds_valid_object
    assert Project.sham!( :build ).valid?
  end

  def test_should_not_allow_nil_name
    project = Project.sham!( :build, :name => nil )
    refute project.valid?
		assert project.invalid?( :name )
		assert project.errors[:name].include?( I18n.t( 'activerecord.errors.models.project.attributes.name.blank' ) )
  end

  def test_should_not_allow_blank_name
    project = Project.sham!( :build, :name => ' ' * Project::NAME_MIN_LENGTH )
    refute project.valid?
		assert project.invalid?( :name )
		assert project.errors[:name].include?( I18n.t( 'activerecord.errors.models.project.attributes.name.blank' ) )
  end

  def test_if_invalid_when_name_length_less_than_min
    project = Project.sham!( :build, :name => 'a' * (Project::NAME_MIN_LENGTH - 1) )
    refute project.valid?
		assert project.invalid?( :name )
		assert project.errors[:name].include?( I18n.t( 'activerecord.errors.models.project.attributes.name.too_short',
      :count => Project::NAME_MIN_LENGTH ) )
  end
  def test_if_valid_when_name_length_equals_min
    project = Project.sham!( :build, :name => 'a' * Project::NAME_MIN_LENGTH )
    assert project.valid?
	end

  def test_if_invalid_when_name_length_greater_than_max
    project = Project.sham!( :build, :name => 'a' * (Project::NAME_MAX_LENGTH + 1) )
    refute project.valid?
		assert project.invalid?( :name )
		assert project.errors[:name].include?( I18n.t( 'activerecord.errors.models.project.attributes.name.too_long',
      :count => Project::NAME_MAX_LENGTH ) )
  end

  def test_if_valid_when_name_length_equals_max
    project = Project.sham!( :build, :name => 'a' * Project::NAME_MAX_LENGTH )
    assert project.valid?
	end

  def test_name_uniqueness
    existing = Project.sham!
    project = Project.sham!( :build, :name => existing.name )
    refute project.valid?
		assert project.errors[:name].include?( I18n.t( 'activerecord.errors.models.project.attributes.name.taken' ) )
  end

  def test_should_not_destroy_countings_while_trying_todestroy_project_with_sections
    project = Project.sham!
    section = Section.sham!(project: project)
    sample = Sample.sham!(section: section)
    counting = Counting.sham!(project: project)
    refute project.destroy
    assert Counting.where(id: counting.id).exists?
    assert project.errors[:base].include?( I18n.t( 'activerecord.errors.models.project.sections.exist' ) )
  end

  def test_destroying_project_destroyes_its_countings
    project = Project.sham!
    countings = []
    5.times { |i| countings << Counting.sham!(project: project) }
    countings.each{ |c| assert Counting.exists?(c.id) }
    assert project.destroy
    countings.each{ |c| refute Counting.exists?(c.id) }
  end

  def test_destroying_project_destroyes_its_research_participations
    project = Project.sham!
    participations = []
    5.times { |i| participations << ResearchParticipation.sham!(project: project) }
    participations.each{ |c| assert ResearchParticipation.exists?(c.id) }
    assert project.destroy
    participations.each{ |c| refute ResearchParticipation.exists?(c.id) }
  end

  def test_should_not_allow_destroying_project_with_sections
    project = Project.sham!
    section = Section.sham!( :project => project )
    refute project.destroy
    assert project.errors[:base].include?( I18n.t( 'activerecord.errors.models.project.sections.exist' ) )
  end

  def test_should_allow_destroying_project_without_sections
    project = Project.sham!
    assert project.sections.empty?
    assert project.destroy
  end

  def test_viewable_by
    user = User.sham!
    expected = []
    5.times do
      expected << ResearchParticipation.sham!(user: user).project
    end
    3.times do
      ResearchParticipation.sham!(user: User.sham!)
    end

    received = Project.viewable_by(user)
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?(e) }
  end

  def test_manageable_by
    user = User.sham!
    expected = []
    3.times do
      expected << ResearchParticipation.sham!(user: user, manager: true).project
    end
    3.times do
      ResearchParticipation.sham!(user: user, manager: false).project
    end
    3.times do
      ResearchParticipation.sham!(user: User.sham!)
    end

    received = Project.manageable_by(user)
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?(e) }
  end
end
