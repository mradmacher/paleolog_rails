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

  def test_should_not_allow_destroying_region_with_wells
    region = Region.sham!
    well = Well.sham!( :region => region )
    refute region.destroy
    assert region.errors[:base].include?( I18n.t( 'activerecord.errors.models.region.wells.exist' ) )
  end

  def test_should_allow_destroying_region_without_wells
    region = Region.sham!
    assert region.wells.empty?
    assert region.destroy
  end

end
