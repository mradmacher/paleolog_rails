require 'test_helper'

class ChoiceTest < ActiveSupport::TestCase
  should 'sham valid object' do
    assert Choice.sham!( :build ).valid?
  end

  should 'belong to field' do
    choice = Choice.sham!( :build )
    choice.field_id = nil
    refute choice.valid?
    assert choice.errors[:field_id].include?( I18n.t( 'activerecord.errors.models.choice.attributes.field_id.blank' ) )
  end

  should 'have a name' do
    choice = Choice.sham!( :build )
    [nil, '', ' ', '  '].each do |v|
      choice.name = v
      refute choice.valid?
      assert choice.errors[:name].include?( I18n.t( 'activerecord.errors.models.choice.attributes.name.blank' ) )
    end
  end

  should 'have a name not longer than maximum' do
    choice = Choice.sham!( :build )
    choice.name = 'a' * (Choice::NAME_MAX_LENGTH + 1)
    refute choice.valid?
    assert choice.errors[:name].include?( I18n.t( 'activerecord.errors.models.choice.attributes.name.too_long',
      count: Choice::NAME_MAX_LENGTH ) )

    choice.name = 'a' * Choice::NAME_MAX_LENGTH
    assert choice.valid?
  end

  should 'have a name unique accros a field' do
    existing = Choice.sham!
    choice = Choice.sham!( :build, field: existing.field, name: existing.name )
    refute choice.valid?
    assert choice.errors[:name].include?( I18n.t( 'activerecord.errors.models.choice.attributes.name.taken' ) )
  end

  should 'not be destroyed when used in a feature' do
    choice = Choice.sham!
    specimen = Specimen.sham!( group: choice.field.group )
    feature = Feature.sham!( choice: choice, specimen: specimen )
    refute choice.destroy
    assert choice.errors[:base].include?( I18n.t( 'activerecord.errors.models.choice.feature.exists' ) )
  end

end

