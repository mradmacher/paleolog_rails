require 'test_helper'

class CountingTest < ActiveSupport::TestCase
  should 'build valid sham' do
    assert Counting.sham!(:build).valid?
  end

  should 'have a name' do
    counting = Counting.sham!( :build )
    [nil, ''].each do |name|
      counting.name = name
      refute counting.valid?
      assert counting.errors[:name].include?( I18n.t( 'activerecord.errors.models.counting.attributes.name.blank' ) )
    end
	end

  should 'not have too short name' do
    counting = Counting.sham!( :build, :name => 'a' * (Counting::NAME_MIN_LENGTH - 1) )
    refute counting.valid?
		assert counting.errors[:name].include?( I18n.t( 'activerecord.errors.models.counting.attributes.name.too_short',
      :count => Counting::NAME_MIN_LENGTH ) )

    counting = Counting.sham!( :build, :name => 'a' * Counting::NAME_MIN_LENGTH )
    assert counting.valid?
  end

  should 'not have too long name' do
    counting = Counting.sham!( :build, :name => 'a' * (Counting::NAME_MAX_LENGTH + 1) )
    refute counting.valid?
		assert counting.errors[:name].include?( I18n.t( 'activerecord.errors.models.counting.attributes.name.too_long',
      :count => Counting::NAME_MAX_LENGTH ) )

    counting = Counting.sham!( :build, :name => 'a' * Counting::NAME_MAX_LENGTH )
    assert counting.valid?
	end

  should 'have a name unique in project' do
    existing = Counting.sham!
    counting = Counting.sham!(:build, :project => existing.project, :name => existing.name )
    refute counting.valid?
		assert counting.errors[:name].include?( I18n.t( 'activerecord.errors.models.counting.attributes.name.taken' ) )
  end

  should 'allow to have same name in different projects' do
    existing = Counting.sham!(project: Project.sham!)
    counting = Counting.sham!(:build, project: Project.sham!, name: existing.name)
		assert counting.valid?
	end

  should 'belong to some project' do
    counting = Counting.sham!(:project => nil )
    refute counting.valid?
		assert counting.errors[:project_id].include?( I18n.t( 'activerecord.errors.models.counting.attributes.project_id.blank' ) )
	end

  should 'check marker count numericality' do
    counting = Counting.sham!
    ['a', '#'].each do |test|
      counting.marker_count = test
      refute counting.valid?
      assert counting.errors[:marker_count].include?( I18n.t( 'activerecord.errors.models.counting.attributes.marker_count.not_a_number' ) )
    end
    [1.1, '1.2'].each do |test|
      counting.marker_count = test
      refute counting.valid?
      assert counting.errors[:marker_count].include?( I18n.t(
        'activerecord.errors.models.counting.attributes.marker_count.not_an_integer' ) )
    end
  end

  should 'check if marker count is greater than zero' do
    counting = Counting.sham!
    counting.marker_count = 0
    refute counting.valid?
    assert counting.errors[:marker_count].include?( I18n.t(
      'activerecord.errors.models.counting.attributes.marker_count.greater_than', :count => 0) )

    [1, 2, 3, 10, 20].each do |test|
      counting.marker_count = test
      assert counting.valid?
    end
  end

  should 'not be destroy with occurrences' do
    counting = Occurrence.sham!.counting
    refute counting.can_be_destroyed?
    refute counting.destroy
    assert counting.errors[:base].include?( I18n.t( 'activerecord.errors.models.counting.occurrences.exist' ) )
  end

  should 'allow to destroy without occurrences' do
    counting = Counting.sham!
    assert counting.occurrences.empty?
    assert counting.can_be_destroyed?
    assert counting.destroy
  end
end
