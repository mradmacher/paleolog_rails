require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def test_if_sham_builds_valid_objects
    assert Group.sham!( :build ).valid?
  end

  def test_if_invalid_when_name_length_less_than_minimum
		group = Group.sham!( :build, :name => 'a' * (Group::NAME_MIN_LENGTH-1) )
    refute group.valid?
    assert group.invalid?( :name )
		assert group.errors[:name].include?( I18n.t(
      'activerecord.errors.models.group.attributes.name.too_short', :count => Group::NAME_MIN_LENGTH ) )
  end

  def test_if_valid_when_name_length_equals_minimum
		group = Group.sham!( :build, :name => 'a' * Group::NAME_MIN_LENGTH )
    assert group.valid?
	end

  def test_if_invalid_when_name_length_greate_than_maximum
		group = Group.sham!( :build, :name => 'a' * (Group::NAME_MAX_LENGTH+1) )
    refute group.valid?
		assert group.invalid?( :name )
		assert group.errors[:name].include?( I18n.t( 
      'activerecord.errors.models.group.attributes.name.too_long', :count => Group::NAME_MAX_LENGTH ) )
  end

  def test_if_valid_when_name_length_equals_maximum
		group = Group.sham!( :build, :name => 'a' * Group::NAME_MAX_LENGTH )
    assert group.valid?
	end

  def test_if_invalid_when_name_not_unique
    existing_group = Group.sham!
    group = Group.sham!( :build, :name => existing_group.name )
    refute group.valid?
		assert group.invalid?( :name )
		assert group.errors[:name].include?( I18n.t( 'activerecord.errors.models.group.attributes.name.taken' ) )
	end
end
