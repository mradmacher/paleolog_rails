require 'test_helper'

class FieldTest < ActiveSupport::TestCase
  should 'sham valid object' do
    assert Field.sham!( :build ).valid?
  end

  should 'belong to group' do
    field = Field.sham!( :build )
    field.group_id = nil
    refute field.valid?
    assert field.errors[:group_id].include?( I18n.t( 'activerecord.errors.models.field.attributes.group_id.blank' ) )
  end

  should 'have a name' do
    field = Field.sham!( :build )
    [nil, '', ' ', '  '].each do |v|
      field.name = v
      refute field.valid?
      assert field.errors[:name].include?( I18n.t( 'activerecord.errors.models.field.attributes.name.blank' ) )
    end
  end

  should 'have a name not longer than maximum' do
    field = Field.sham!( :build )
    field.name = 'a' * (Field::NAME_MAX_LENGTH + 1)
    refute field.valid?
    refute field.errors[:name].empty?
    assert field.errors[:name].include?( I18n.t( 'activerecord.errors.models.field.attributes.name.too_long', 
      count: Field::NAME_MAX_LENGTH ) )

    field.name = 'a' * Field::NAME_MAX_LENGTH
    assert field.valid?
  end

  should 'have a name unique accros a group' do
    existing = Field.sham!( :create )
    field = Field.sham!( :build, group: existing.group, name: existing.name )
    refute field.valid?
    assert field.errors[:name].include?( I18n.t( 'activerecord.errors.models.field.attributes.name.taken' ) )
  end

  should 'not be destroyed when used in a feature' do
    feature = Feature.sham!
    field = feature.choice.field
    refute field.destroy
    assert field.errors[:base].include?( I18n.t( 'activerecord.errors.models.field.feature.exists' ) )
  end

  should 'destroy dependent choices' do
    group = Group.sham!
    field = Field.sham!( group: group )
    choice = Choice.sham!( field: field )

    assert Choice.where( id: choice.id ).exists?
    field.destroy
    refute Choice.where( id: choice.id ).exists?
  end

end

