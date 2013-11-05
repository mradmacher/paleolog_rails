require 'test_helper'

class WellTest < ActiveSupport::TestCase
  def test_if_sham_build_valid_well
    assert Well.sham!( :build ).valid?
  end

  def test_should_not_allow_nil_name
    well = Well.sham!( :build, :name => nil )
    refute well.valid?
	  assert well.invalid?( :name )
	  assert well.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.well.attributes.name.blank' ) )
  end

  def test_should_not_allow_empty_name
	  well = Well.sham!( :build, :name => ' ' )
    refute well.valid?
	  assert well.invalid?( :name )
	  assert well.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.well.attributes.name.blank' ) )
  end

  def test_region_presence
    well = Well.sham!( :build, :region => nil )
    refute well.valid?
	  assert well.invalid?( :region_id )
	  assert well.errors[ :region_id ].include?( I18n.t( 'activerecord.errors.models.well.attributes.region_id.blank' ) )
  end

  def test_name_uniqueness_in_region
    existing_well = Well.sham!
    well = Well.sham!( :build, :region => existing_well.region, :name => existing_well.name )
    refute well.valid?
	  assert well.invalid?( :name )
	  assert well.errors[ :name ].include?( I18n.t( 'activerecord.errors.models.well.attributes.name.taken' ) )
  end

  def test_should_allow_same_names_in_different_regions
    existing_well = Well.sham!( :build, :region => Region.sham! )
    well = Well.sham!( :build, :region => Region.sham!, :name => existing_well.name )
    assert well.valid?
  end

  def test_should_not_allow_destroying_well_with_samples
    well = Well.sham!
    sample = Sample.sham!( :well => well )
    refute well.destroy
    assert well.errors[:base].include?( I18n.t( 'activerecord.errors.models.well.samples.exist' ) )
  end

  def test_should_allow_destroying_well_without_samples
    well = Well.sham!
    assert well.samples.empty?
    assert well.destroy
  end

  def test_it_should_not_destroy_countings_while_destroying_well_with_samples
    well = Well.sham!
    sample = Sample.sham!( :well => well )
    counting = Counting.sham!( :well => well )
    refute well.destroy
    assert Counting.where( :id => counting.id ).exists?
    assert well.errors[:base].include?( I18n.t( 'activerecord.errors.models.well.samples.exist' ) )
  end

  def test_if_destroying_well_destroyes_its_countings
    well = Well.sham!
    countings = []
    5.times { |i| countings << Counting.sham!( :well => well ) }
    countings.each{ |c| assert Counting.exists?( c.id ) }
    assert well.destroy
    countings.each{ |c| refute Counting.exists?( c.id ) }
  end

  def test_if_destroying_well_destroyes_its_research_participations
    well = Well.sham!
    participations = []
    5.times { |i| participations << ResearchParticipation.sham!( well: well ) }
    participations.each{ |c| assert ResearchParticipation.exists?( c.id ) }
    assert well.destroy
    participations.each{ |c| refute ResearchParticipation.exists?( c.id ) }
  end

  def test_id_samples_orderd_by_bottom_depth_asc
    well = Well.sham!
    Sample.sham!( :well => well, :bottom_depth => 100.0, :top_depth => 80.0 )
    Sample.sham!( :well => well, :bottom_depth => 50.0, :top_depth => 20.0 )
    Sample.sham!( :well => well, :bottom_depth => 20.0, :top_depth => 10.0 )
    Sample.sham!( :well => well, :bottom_depth => 70.0, :top_depth => 50.0 )
    previous_depth = nil
    well.samples.each do |s|
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
      expected << ResearchParticipation.sham!( user: user ).well
    end
    3.times do
      ResearchParticipation.sham!( user: User.sham! )
    end

    received = Well.viewable_by user
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?( e ) }
  end

  def test_manageable_by
    user = User.sham!
    expected = []
    3.times do
      expected << ResearchParticipation.sham!( user: user, manager: true ).well
    end
    3.times do
      ResearchParticipation.sham!( user: user, manager: false ).well
    end
    3.times do
      ResearchParticipation.sham!( user: User.sham! )
    end

    received = Well.manageable_by user
    assert_equal expected.size, received.size
    expected.each { |e| assert received.include?( e ) }
  end
end
