require 'test_helper'

class FeatureTest < ActiveSupport::TestCase
  should 'sham valid object' do
    assert Feature.sham!( :build ).valid?
  end

  should 'belong to choice' do
    feature = Feature.sham!( :build )
    feature.choice_id = nil
    refute feature.valid?
    assert feature.errors[:choice_id].include?( I18n.t( 'activerecord.errors.models.feature.attributes.choice_id.blank' ) )
  end

  should 'belong to specimen' do
    feature = Feature.sham!( :build )
    feature.specimen_id = nil
    refute feature.valid?
    assert feature.errors[:specimen_id].include?( I18n.t( 'activerecord.errors.models.feature.attributes.specimen_id.blank' ) )
  end

  should 'have unique choice accross a specimen' do
    existing = Feature.sham!( :create )
    feature = Feature.sham!( :build, specimen: existing.specimen, choice: existing.choice )
    refute feature.valid?
    assert feature.errors[:choice_id].include?( I18n.t( 'activerecord.errors.models.feature.attributes.choice_id.taken' ) )
  end

  should 'have at least one choice accross a field' do
    field = Field.sham!
    choice1 = Choice.sham!( field: field )
    choice2 = Choice.sham!( field: field )
    specimen = Specimen.sham!( group: field.group )

    existing = Feature.sham!( specimen: specimen, choice: choice1 )
    feature = Feature.sham!( :build, specimen: specimen, choice: choice2 )
    refute feature.valid?
    assert feature.errors[:choice_id].include?( I18n.t( 'activerecord.errors.models.feature.attributes.choice_id.taken' ) )
  end

  should 'allow to change choice accross a field' do
    field = Field.sham!
    choice1 = Choice.sham!( field: field )
    choice2 = Choice.sham!( field: field )
    specimen = Specimen.sham!( group: field.group )

    feature = Feature.sham!( specimen: specimen, choice: choice1 )
    feature.choice = choice2
    assert feature.valid?
  end

  should 'accept choice and specimen from the same group' do
    group = Group.sham!
    field = Field.sham!( group: group )
    choice = Choice.sham!( field: field )
    specimen = Specimen.sham!( group: group )
    feature = Feature.sham!( :build, specimen: specimen, choice: choice )
    assert feature.valid?
  end

  should 'not accept choice and specimen from different groups' do
    group1 = Group.sham!
    group2 = Group.sham!
    field = Field.sham!( group: group1)
    choice = Choice.sham!( field: field )
    specimen = Specimen.sham!( group: group2)
    feature = Feature.sham!( :build, specimen: specimen, choice: choice )
    refute feature.valid?
    assert feature.errors[:choice_id].include?( I18n.t( 'activerecord.errors.models.feature.attributes.choice_id.invalid_group' ) )
  end
end

