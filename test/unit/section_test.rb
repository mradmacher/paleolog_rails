require 'test_helper'

class SectionTest < ActiveSupport::TestCase
  def test_if_sham_build_valid_section
    assert Section.sham!( :build ).valid?
  end

  def test_should_not_allow_nil_name
    section = Section.sham!( :build, :name => nil )
    refute section.valid?
	  assert section.invalid?( :name )
	  assert section.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.section.attributes.name.blank' ) )
  end

  def test_should_not_allow_empty_name
	  section = Section.sham!( :build, :name => ' ' )
    refute section.valid?
	  assert section.invalid?( :name )
	  assert section.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.section.attributes.name.blank' ) )
  end

  def test_project_presence
    section = Section.sham!( :build, :project => nil )
    refute section.valid?
	  assert section.invalid?( :project_id )
	  assert section.errors[ :project_id ].include?( I18n.t( 'activerecord.errors.models.section.attributes.project_id.blank' ) )
  end

  def test_name_uniqueness_in_project
    existing_section = Section.sham!
    section = Section.sham!( :build, :project => existing_section.project, :name => existing_section.name )
    refute section.valid?
	  assert section.invalid?( :name )
	  assert section.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.section.attributes.name.taken' ) )
  end

  def test_should_allow_same_names_in_different_projects
    existing_section = Section.sham!( :build, :project => Project.sham! )
    section = Section.sham!( :build, :project => Project.sham!, :name => existing_section.name )
    assert section.valid?
  end

  def test_should_not_allow_destroying_section_with_samples
    section = Section.sham!
    sample = Sample.sham!( :section => section )
    refute section.destroy
    assert section.errors[:base].include?( I18n.t( 'activerecord.errors.models.section.samples.exist' ) )
  end

  def test_should_allow_destroying_section_without_samples
    section = Section.sham!
    assert section.samples.empty?
    assert section.destroy
  end

  def test_viewable_by
    user = User.sham!
    expected = []
    5.times do
      project = ResearchParticipation.sham!(user: user).project
      expected << Section.sham!(project: project)
    end
    3.times do
      project = ResearchParticipation.sham!(user: User.sham!).project
      Section.sham!(project: project)
    end

    received = Section.viewable_by(user)
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?( e ) }
  end

  def test_manageable_by
    user = User.sham!
    expected = []
    3.times do
      project = ResearchParticipation.sham!(user: user, manager: true).project
      expected << Section.sham!(project: project)
    end
    3.times do
      project = ResearchParticipation.sham!( user: user, manager: false).project
      Section.sham!(project: project)
    end
    3.times do
      project = ResearchParticipation.sham!(user: User.sham!).project
      Section.sham!(project: project)
    end

    received = Section.manageable_by user
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?( e ) }
  end
end
