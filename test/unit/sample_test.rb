require 'test_helper'

class SampleTest < ActiveSupport::TestCase
  def test_it_should_be_valid
    assert Sample.sham!( :build ).valid?
  end

	def test_it_should_have_a_name
		sample = Sample.sham!( :build, :name => nil )
    refute sample.valid?
		assert sample.invalid?( :name )
		assert sample.errors[:name].include?( I18n.t( 'activerecord.errors.models.sample.attributes.name.blank' ) )
	end

	def test_it_should_have_not_empty_name
		sample = Sample.sham!( :build, :name => ' ' * Sample::NAME_MIN_LENGTH )
    refute sample.valid?
		assert sample.invalid?( :name )
		assert sample.errors[:name].include?( I18n.t( 'activerecord.errors.models.sample.attributes.name.blank' ) )
	end

  def test_it_should_have_name_not_shorter_than_min
    sample = Sample.sham!( :build, :name => 'a' * (Sample::NAME_MIN_LENGTH - 1) )
    refute sample.valid?
		assert sample.invalid?( :name )
		assert sample.errors[:name].include?( I18n.t( 'activerecord.errors.models.sample.attributes.name.too_short',
      :count => Sample::NAME_MIN_LENGTH ) )
  end

  def test_it_should_be_valid_when_name_length_equals_min
    sample = Sample.sham!( :build, :name => 'a' * Sample::NAME_MIN_LENGTH )
    assert sample.valid?
	end

  def test_it_should_have_name_not_longer_than_max
    sample = Sample.sham!( :build, :name => 'a' * (Sample::NAME_MAX_LENGTH + 1) )
    refute sample.valid?
		assert sample.invalid?( :name )
		assert sample.errors[:name].include?( I18n.t( 'activerecord.errors.models.sample.attributes.name.too_long',
      :count => Sample::NAME_MAX_LENGTH ) )
  end

  def test_it_should_be_valid_when_name_length_equals_max
    sample = Sample.sham!( :build, :name => 'a' * Sample::NAME_MAX_LENGTH )
    assert sample.valid?
	end

  def test_it_should_have_numerical_weight
    sample = Sample.sham!( :build )
    ['a', '#', '34a', 'a34'].each do |test|
      sample.weight = test
      refute sample.valid?
      assert sample.errors[:weight].any?
      assert sample.errors[:weight].include?( I18n.t( 'activerecord.errors.models.sample.attributes.weight.not_a_number'  ) )
    end

    ['1.3', 1.3, 12].each do |test|
      sample.weight = test
      assert sample.valid?
    end
  end

  def test_weight_is_grater_than_zero
    sample = Sample.sham!
    sample.weight = 0.0
    refute sample.valid?
    assert sample.errors[:weight].include?( I18n.t(
      'activerecord.errors.models.sample.attributes.weight.greater_than', :count => 0.0) )

    [0.1, 2.0, 0.000001, 20].each do |test|
      sample.weight = test
      assert sample.valid?
    end
  end

  def test_it_should_have_unique_name_in_section
    existing_sample = Sample.sham!
    sample = Sample.sham!( :section => existing_sample.section, :name => existing_sample.name )
    refute sample.valid?
    assert sample.invalid?( :name )
		assert sample.errors[:name].include?( I18n.t( 'activerecord.errors.models.sample.attributes.name.taken' ) )
  end

  def test_it_can_have_same_name_in_different_sections
    existing_sample = Sample.sham!
    sample = Sample.sham!( :section => Section.sham!, :name => existing_sample.name )
    assert sample.valid?
	end

  def test_it_should_have_section
		sample = Sample.sham!( :build, :section => nil )
    refute sample.valid?
		assert sample.invalid?( :section_id )
		assert sample.errors[:section_id].include?( I18n.t( 'activerecord.errors.models.sample.attributes.section_id.blank' ) )
  end

  def test_it_should_not_destroy_sample_with_occurrences
    sample = Occurrence.sham!.sample
    refute sample.destroy
    assert sample.errors[:base].include?( I18n.t( 'activerecord.errors.models.sample.occurrences.exist' ) )
  end

  def test_it_should_destroy_sample_without_occurrences
    sample = Sample.sham!
    assert sample.occurrences.empty?
    assert sample.destroy
  end

  test 'have a rank' do
    sample = Sample.sham!(:build, rank: nil)
    refute sample.valid?
		assert sample.errors[:rank].include? I18n.t( 'activerecord.errors.models.sample.attributes.rank.blank' )
	end

  test 'have unique rank in section' do
    existing = Sample.sham!
    sample = Sample.sham!(:build, section: existing.section, rank: existing.rank)
    refute sample.valid?
		assert sample.errors[:rank].include? I18n.t('activerecord.errors.models.sample.attributes.rank.taken')
	end

  test 'allow to repeat rank in different sections' do
    section1 = Section.sham!
    section2 = Section.sham!
    existing = Sample.sham!(section: section1)
    sample = Sample.sham!(:build, section: section2, rank: existing.rank)
    assert sample.valid?
	end

  test 'samples are orderd by rank' do
    section = Section.sham!
    Sample.sham!(section: section, name: 'a', rank: 3)
    Sample.sham!(section: section, name: 'b', rank: 1)
    Sample.sham!(section: section, name: 'c', rank: 2)
    Sample.sham!(section: section, name: 'd', rank: 4)
    ordered = section.samples.ordered.map(&:name)
    assert ['b', 'c', 'a', 'd'], ordered
  end
end
