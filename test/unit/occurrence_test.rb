require 'test_helper'

class OccurrenceTest < ActiveSupport::TestCase
  should 'build valid sham' do
    assert Occurrence.sham!( :build ).valid?
  end

  should 'have a specimen' do
    occurrence = Occurrence.sham!( :build, :specimen => nil )
    refute occurrence.valid?
		assert occurrence.errors[:specimen_id].include? I18n.t( 
      'activerecord.errors.models.occurrence.attributes.specimen_id.blank' )
	end

  should 'have a counting' do 
    occurrence = Occurrence.sham!( :build, :counting => nil )
    refute occurrence.valid?
		assert occurrence.errors[:counting_id].include? I18n.t( 
      'activerecord.errors.models.occurrence.attributes.counting_id.blank' )
  end

  should 'have a sample' do
    occurrence = Occurrence.sham!( :build, :sample => nil )
    refute occurrence.valid?
		assert occurrence.errors[:sample_id].include? I18n.t( 
      'activerecord.errors.models.occurrence.attributes.sample_id.blank' )
  end

  should 'have both sample and counting from the same well' do
    well1 = Well.sham!
    well2 = Well.sham!
    occurrence = Occurrence.sham!( :build,
      :counting => Counting.sham!( :well => well1 ), :sample => Sample.sham!( :well => well2 ) )
    refute occurrence.valid?
		assert occurrence.errors[:sample_id].include? I18n.t(
      'activerecord.errors.models.occurrence.attributes.sample_id.invalid' )
  end

  should 'have a rank' do
    occurrence = Occurrence.sham!( :build, :rank => nil )
    refute occurrence.valid?
		assert occurrence.errors[:rank].include? I18n.t( 'activerecord.errors.models.occurrence.attributes.rank.blank' )
	end

  should 'have unique rank is counting and sample scope' do
    existing = Occurrence.sham!
    occurrence = Occurrence.sham!( :build, :counting => existing.counting, :sample => existing.sample,
      :rank => existing.rank )
    refute occurrence.valid?
		assert occurrence.errors[:rank].include? I18n.t( 'activerecord.errors.models.occurrence.attributes.rank.taken' )
	end

  should 'allow to repeat rank id different countings from the same sample' do
    well = Well.sham!
    sample = Sample.sham!( :well => well )
    counting1 = Counting.sham!( :well => well )
    counting2 = Counting.sham!( :well => well )
    existing = Occurrence.sham!( sample: sample, counting: counting1 )
    occurrence = Occurrence.sham!( :build, sample: sample, counting: counting2, :rank => existing.rank )
    assert occurrence.valid?
	end

  should 'allow to repeat rank in different samples from the same counting' do
    well = Well.sham!
    counting = Counting.sham!( :well => well )
    sample1 = Sample.sham!( :well => well )
    sample2 = Sample.sham!( :well => well )
    existing = Occurrence.sham!( :counting => counting, :sample => sample1, :specimen => Specimen.sham! )
    occurrence = Occurrence.sham!( :build, :counting => counting, :sample => sample2, :specimen => Specimen.sham!,
      :rank => existing.rank )
    assert occurrence.valid?
	end

  should 'allow to repeat rank in different samples and countings' do
    well = Well.sham!
    counting1 = Counting.sham!( well: well )
    counting2 = Counting.sham!( well: well )
    sample1 = Sample.sham!( well: well )
    sample2 = Sample.sham!( well: well )
    existing = Occurrence.sham!( counting: counting1, sample: sample1, specimen: Specimen.sham! )
    occurrence = Occurrence.sham!( counting: counting2, sample: sample2, specimen: Specimen.sham!,
      :rank => existing.rank )
    assert occurrence.valid?
	end

	should 'have unique specimen in counting and sample scope' do
    existing = Occurrence.sham!
    occurrence = Occurrence.sham!( :build, counting: existing.counting, sample: existing.sample,
      specimen: existing.specimen )
    refute occurrence.valid?
		assert occurrence.errors[:specimen_id].include?( I18n.t( 'activerecord.errors.models.occurrence.attributes.specimen_id.taken' ) )
	end

	should 'allow to repeat specimens in different countings of the same sampel' do
    well = Well.sham!
    sample = Sample.sham!( well: well )
    counting1 = Counting.sham!( well: well )
    counting2 = Counting.sham!( well: well )
    existing = Occurrence.sham!( sample: sample, counting: counting1 )
    occurrence = Occurrence.sham!( :build, sample: sample, counting: counting2, specimen: existing.specimen )
    assert occurrence.valid?
	end

  should 'allow to repeat specimens in different samples from the same counting' do
    well = Well.sham!
    counting = Counting.sham!( well: well )
    sample1 = Sample.sham!( well: well )
    sample2 = Sample.sham!( well: well )
    existing = Occurrence.sham!( counting: counting, sample: sample1 )
    occurrence = Occurrence.sham!( :build, counting: counting, sample: sample2, specimen: existing.specimen )
    assert occurrence.valid?
	end

  should 'allow to repeat specimens in different samples and countings' do
    well = Well.sham!
    counting1 = Counting.sham!( well: well )
    counting2 = Counting.sham!( well: well )
    sample1 = Sample.sham!( well: well )
    sample2 = Sample.sham!( well: well )
    existing = Occurrence.sham!( counting: counting1, sample: sample1 )
    occurrence = Occurrence.sham!( counting: counting2, sample: sample2, specimen: existing.specimen )
    assert occurrence.valid?
	end

  should 'accept valid statuses' do
    occurrence = Occurrence.sham!( :build )
    [Occurrence::NORMAL, Occurrence::OUTSIDE_COUNT, Occurrence::CARVING, Occurrence::REWORKING].each do |status|
      occurrence.status = status
      assert occurrence.valid?
    end
  end

  should 'have some status' do
    occurrence = Occurrence.sham!( :build, status: nil )
    refute occurrence.valid?
		assert occurrence.errors[:status].include?( I18n.t( 'activerecord.errors.models.occurrence.attributes.status.blank' ) )
	end

  should 'refute invalid statuese' do
    occurrence = Occurrence.sham!( :build )
    [-100, -1, 4, 5, 100].each do |status|
      occurrence.status = status
      refute occurrence.valid?, status.to_s
      assert occurrence.errors[:status].include?( I18n.t( 'activerecord.errors.models.occurrence.attributes.status.inclusion' ) )
    end
  end
  
  should 'be normal when status is normal' do
    occurrence = Occurrence.sham!( :build, status: Occurrence::NORMAL )
    assert occurrence.normal?
  end

  should 'be outside of count when status is outside of count' do
    occurrence = Occurrence.sham!( :build, status: Occurrence::OUTSIDE_COUNT )
    assert occurrence.outside_count?
  end

  should 'be carving when status is carving' do
    occurrence = Occurrence.sham!( :build, status: Occurrence::CARVING )
    assert occurrence.carving?
  end

  should 'be reworking when status is reworking' do
    occurrence = Occurrence.sham!( :build, status: Occurrence::REWORKING )
    assert occurrence.reworking?
  end

  should 'retrieve proper status symbol' do
    occurrence = Occurrence.sham!( :build )
    occurrence.status = Occurrence::NORMAL
    assert_equal '', occurrence.status_symbol
    occurrence.status = Occurrence::OUTSIDE_COUNT
    assert_equal '+', occurrence.status_symbol
    occurrence.status = Occurrence::CARVING
    assert_equal 'c', occurrence.status_symbol
    occurrence.status = Occurrence::REWORKING
    assert_equal 'r', occurrence.status_symbol
  end

end
