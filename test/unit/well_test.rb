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

  def test_region_presence
    section = Section.sham!( :build, :region => nil )
    refute section.valid?
	  assert section.invalid?( :region_id )
	  assert section.errors[ :region_id ].include?( I18n.t( 'activerecord.errors.models.section.attributes.region_id.blank' ) )
  end

  def test_name_uniqueness_in_region
    existing_section = Section.sham!
    section = Section.sham!( :build, :region => existing_section.region, :name => existing_section.name )
    refute section.valid?
	  assert section.invalid?( :name )
	  assert section.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.section.attributes.name.taken' ) )
  end

  def test_should_allow_same_names_in_different_regions
    existing_section = Section.sham!( :build, :region => Region.sham! )
    section = Section.sham!( :build, :region => Region.sham!, :name => existing_section.name )
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

  def test_if_samples_orderd_by_bottom_depth_asc
    section = Section.sham!
    Sample.sham!(:section => section, :bottom_depth => 100.0, :top_depth => 80.0)
    Sample.sham!(:section => section, :bottom_depth => 50.0, :top_depth => 20.0)
    Sample.sham!(:section => section, :bottom_depth => 20.0, :top_depth => 10.0)
    Sample.sham!(:section => section, :bottom_depth => 70.0, :top_depth => 50.0)
    previous_depth = nil
    section.samples.each do |s|
      unless previous_depth.nil?
        assert s.bottom_depth > previous_depth
      else
        previous_depth = s.bottom_depth
      end
    end
  end

  def test_viewable_by
    user = User.sham!
    expected = []
    5.times do
      region = ResearchParticipation.sham!(user: user).region
      expected << Section.sham!(region: region)
    end
    3.times do
      region = ResearchParticipation.sham!(user: User.sham!).region
      Section.sham!(region: region)
    end

    received = Section.viewable_by(user)
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?( e ) }
  end

  def test_manageable_by
    user = User.sham!
    expected = []
    3.times do
      region = ResearchParticipation.sham!(user: user, manager: true).region
      expected << Section.sham!(region: region)
    end
    3.times do
      region = ResearchParticipation.sham!( user: user, manager: false).region
      Section.sham!(region: region)
    end
    3.times do
      region = ResearchParticipation.sham!(user: User.sham!).region
      Section.sham!(region: region)
    end

    received = Section.manageable_by user
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?( e ) }
  end
end
