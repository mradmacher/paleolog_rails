require 'test_helper'

class RegionTest < ActiveSupport::TestCase
  def test_if_sham_builds_valid_object
    assert Region.sham!( :build ).valid?
  end

  def test_should_not_allow_nil_name
    region = Region.sham!( :build, :name => nil )
    refute region.valid?
		assert region.invalid?( :name )
		assert region.errors[:name].include?( I18n.t( 'activerecord.errors.models.region.attributes.name.blank' ) )
  end

  def test_should_not_allow_blank_name
    region = Region.sham!( :build, :name => ' ' * Region::NAME_MIN_LENGTH )
    refute region.valid?
		assert region.invalid?( :name )
		assert region.errors[:name].include?( I18n.t( 'activerecord.errors.models.region.attributes.name.blank' ) )
  end

  def test_if_invalid_when_name_length_less_than_min
    region = Region.sham!( :build, :name => 'a' * (Region::NAME_MIN_LENGTH - 1) )
    refute region.valid?
		assert region.invalid?( :name )
		assert region.errors[:name].include?( I18n.t( 'activerecord.errors.models.region.attributes.name.too_short',
      :count => Region::NAME_MIN_LENGTH ) )
  end
  def test_if_valid_when_name_length_equals_min
    region = Region.sham!( :build, :name => 'a' * Region::NAME_MIN_LENGTH )
    assert region.valid?
	end

  def test_if_invalid_when_name_length_greater_than_max
    region = Region.sham!( :build, :name => 'a' * (Region::NAME_MAX_LENGTH + 1) )
    refute region.valid?
		assert region.invalid?( :name )
		assert region.errors[:name].include?( I18n.t( 'activerecord.errors.models.region.attributes.name.too_long',
      :count => Region::NAME_MAX_LENGTH ) )
  end

  def test_if_valid_when_name_length_equals_max
    region = Region.sham!( :build, :name => 'a' * Region::NAME_MAX_LENGTH )
    assert region.valid?
	end

  def test_name_uniqueness
    existing = Region.sham!
    region = Region.sham!( :build, :name => existing.name )
    refute region.valid?
		assert region.errors[:name].include?( I18n.t( 'activerecord.errors.models.region.attributes.name.taken' ) )
  end

  def test_should_not_destroy_countings_while_trying_todestroy_region_with_sections
    region = Region.sham!
    section = Section.sham!(region: region)
    sample = Sample.sham!(section: section)
    counting = Counting.sham!(region: region)
    refute region.destroy
    assert Counting.where(id: counting.id).exists?
    assert region.errors[:base].include?( I18n.t( 'activerecord.errors.models.region.sections.exist' ) )
  end

  def test_destroying_region_destroyes_its_countings
    region = Region.sham!
    countings = []
    5.times { |i| countings << Counting.sham!(region: region) }
    countings.each{ |c| assert Counting.exists?(c.id) }
    assert region.destroy
    countings.each{ |c| refute Counting.exists?(c.id) }
  end

  def test_destroying_region_destroyes_its_research_participations
    region = Region.sham!
    participations = []
    5.times { |i| participations << ResearchParticipation.sham!(region: region) }
    participations.each{ |c| assert ResearchParticipation.exists?(c.id) }
    assert region.destroy
    participations.each{ |c| refute ResearchParticipation.exists?(c.id) }
  end

  def test_should_not_allow_destroying_region_with_sections
    region = Region.sham!
    section = Section.sham!( :region => region )
    refute region.destroy
    assert region.errors[:base].include?( I18n.t( 'activerecord.errors.models.region.sections.exist' ) )
  end

  def test_should_allow_destroying_region_without_sections
    region = Region.sham!
    assert region.sections.empty?
    assert region.destroy
  end

  def test_viewable_by
    user = User.sham!
    expected = []
    5.times do
      expected << ResearchParticipation.sham!(user: user).region
    end
    3.times do
      ResearchParticipation.sham!(user: User.sham!)
    end

    received = Region.viewable_by(user)
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?(e) }
  end

  def test_manageable_by
    user = User.sham!
    expected = []
    3.times do
      expected << ResearchParticipation.sham!(user: user, manager: true).region
    end
    3.times do
      ResearchParticipation.sham!(user: user, manager: false).region
    end
    3.times do
      ResearchParticipation.sham!(user: User.sham!)
    end

    received = Region.manageable_by(user)
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?(e) }
  end
end
