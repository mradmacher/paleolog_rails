require 'test_helper'

class CountingMergeTest < ActiveSupport::TestCase
  def setup
    @project = Project.sham!
    @section = Section.sham!(project: @project)
    @counting = Counting.sham!(project: @project)
    @sample1 = Sample.sham!(section: @section)
    @sample2 = Sample.sham!(section: @section)
    @specimen1 = Specimen.sham!
    @specimen2 = Specimen.sham!
    @specimen3 = Specimen.sham!
    @specimen4 = Specimen.sham!

    Occurrence.sham!(counting: @counting, sample: @sample1, specimen: @specimen1, quantity: 1, rank: 1)
    Occurrence.sham!(counting: @counting, sample: @sample1, specimen: @specimen2, quantity: 2, rank: 2)
    Occurrence.sham!(counting: @counting, sample: @sample1, specimen: @specimen3, quantity: 3, rank: 3)
    Occurrence.sham!(counting: @counting, sample: @sample1, specimen: @specimen4, quantity: 4, rank: 4)

    Occurrence.sham!(counting: @counting, sample: @sample2, specimen: @specimen4, quantity: 1, rank: 1)
    Occurrence.sham!(counting: @counting, sample: @sample2, specimen: @specimen3, quantity: 2, rank: 2)
    Occurrence.sham!(counting: @counting, sample: @sample2, specimen: @specimen2, quantity: 3, rank: 3)
    Occurrence.sham!(counting: @counting, sample: @sample2, specimen: @specimen1, quantity: 4, rank: 4)
    @merger = CountingMerge.new(@counting)
    @scope1 = Occurrence.where(sample_id: @sample1.id)
    @scope2 = Occurrence.where(sample_id: @sample2.id)
  end

  def test_does_not_touch_other_countings
    @other_counting = Counting.sham!(project: @project)
    Occurrence.sham!(counting: @other_counting, sample: @sample1, specimen: @specimen1, quantity: 1, rank: 1)
    Occurrence.sham!(counting: @other_counting, sample: @sample1, specimen: @specimen2, quantity: 2, rank: 2)
    Occurrence.sham!(counting: @other_counting, sample: @sample1, specimen: @specimen3, quantity: 3, rank: 3)
    Occurrence.sham!(counting: @other_counting, sample: @sample1, specimen: @specimen4, quantity: 4, rank: 4)

    assert_equal 4, Occurrence.where(counting_id: @other_counting.id, sample_id: @sample1.id).count
    assert_equal 4, Occurrence.where(counting_id: @other_counting.id, sample_id: @sample1.id).map(&:specimen_id).uniq.size

    @merger.move(@sample1, from: @specimen4, to: @specimen2)
    @merger.move(@sample2, from: @specimen4, to: @specimen2)

    assert_equal 4, Occurrence.where(counting_id: @other_counting.id, sample_id: @sample1.id).count
    assert_equal 4, Occurrence.where(counting_id: @other_counting.id, sample_id: @sample1.id).map(&:specimen_id).uniq.size
  end

  def test_does_nothing_when_from_specimen_not_present
    @scope1.where(specimen_id: @specimen4.id).destroy_all

    occurrences = @scope1.order(rank: :asc).entries
    assert_equal 3, occurrences.size
    assert_equal @specimen1.id, occurrences[0].specimen_id
    assert_equal 1, occurrences[0].quantity
    assert_equal @specimen2.id, occurrences[1].specimen_id
    assert_equal 2, occurrences[1].quantity
    assert_equal @specimen3.id, occurrences[2].specimen_id
    assert_equal 3, occurrences[2].quantity

    @merger.move(@sample1, from: @specimen4, to: @specimen2)

    occurrences = @scope1.order(rank: :asc).entries
    assert_equal 3, occurrences.size
    assert_equal @specimen1.id, occurrences[0].specimen_id
    assert_equal 1, occurrences[0].quantity
    assert_equal @specimen2.id, occurrences[1].specimen_id
    assert_equal 2, occurrences[1].quantity
    assert_equal @specimen3.id, occurrences[2].specimen_id
    assert_equal 3, occurrences[2].quantity
  end

  def test_just_changes_specimen_when_to_specimen_not_present
    @scope1.where(specimen_id: @specimen2.id).destroy_all

    occurrences = @scope1.order(rank: :asc).entries
    assert_equal 3, occurrences.size
    assert_equal @specimen1.id, occurrences[0].specimen_id
    assert_equal 1, occurrences[0].quantity
    assert_equal @specimen3.id, occurrences[1].specimen_id
    assert_equal 3, occurrences[1].quantity
    assert_equal @specimen4.id, occurrences[2].specimen_id
    assert_equal 4, occurrences[2].quantity

    @merger.move(@sample1, from: @specimen4, to: @specimen2)

    occurrences = @scope1.order(rank: :asc).entries
    assert_equal 3, occurrences.size
    assert_equal @specimen1.id, occurrences[0].specimen_id
    assert_equal 1, occurrences[0].quantity
    assert_equal @specimen3.id, occurrences[1].specimen_id
    assert_equal 3, occurrences[1].quantity
    assert_equal @specimen2.id, occurrences[2].specimen_id
    assert_equal 4, occurrences[2].quantity
  end

  def test_ignores_empty_quantities
    # specimen4 does not have quantity, specimen2 does
    @scope1.where(specimen_id: @specimen4).update_all(quantity: nil)
    # specimen2 does not have quantity, specimen4 does
    @scope2.where(specimen_id: @specimen2).update_all(quantity: nil)

    @merger.move(@sample1, from: @specimen4, to: @specimen2)
    @merger.move(@sample2, from: @specimen4, to: @specimen2)

    assert_equal 2, @scope1.where(specimen_id: @specimen2.id).first.quantity # specimen2 quantity remains
    assert_equal 1, @scope2.where(specimen_id: @specimen2.id).first.quantity # specimen4 quantity remains
  end

  def test_leaves_empty_quantity_when_both_empty
    @scope1.where(specimen_id: [@specimen2.id, @specimen4.id]).update_all(quantity: nil)
    @scope2.where(specimen_id: [@specimen2.id, @specimen4.id]).update_all(quantity: nil)

    @merger.move(@sample1, from: @specimen4, to: @specimen2)
    @merger.move(@sample2, from: @specimen4, to: @specimen2)

    assert_nil @scope1.where(specimen_id: @specimen2.id).first.quantity
    assert_nil @scope2.where(specimen_id: @specimen2.id).first.quantity
  end

  def test_can_merge_to_new_specimen
    @new_specimen = Specimen.sham!

    @merger.move(@sample1, from: @specimen4, to: @new_specimen)
    @merger.move(@sample2, from: @specimen4, to: @new_specimen)
    @merger.move(@sample1, from: @specimen2, to: @new_specimen)
    @merger.move(@sample2, from: @specimen2, to: @new_specimen)

    assert_equal 3, @scope1.count
    specimens = @scope1.map(&:specimen_id)
    assert specimens.include?(@specimen1.id)
    assert specimens.include?(@new_specimen.id)
    assert specimens.include?(@specimen3.id)

    assert_equal 1, @scope1.where(specimen_id: @specimen1.id).first.rank
    assert_equal 2, @scope1.where(specimen_id: @new_specimen.id).first.rank
    assert_equal 3, @scope1.where(specimen_id: @specimen3.id).first.rank

    assert_equal 1, @scope1.where(specimen_id: @specimen1.id).first.quantity
    assert_equal 6, @scope1.where(specimen_id: @new_specimen.id).first.quantity
    assert_equal 3, @scope1.where(specimen_id: @specimen3.id).first.quantity

    assert_equal 3, @scope2.count
    specimens = @scope2.map(&:specimen_id)
    assert specimens.include?(@specimen1.id)
    assert specimens.include?(@new_specimen.id)
    assert specimens.include?(@specimen3.id)

    assert_equal 4, @scope2.where(specimen_id: @specimen1.id).first.rank
    assert_equal 1, @scope2.where(specimen_id: @new_specimen.id).first.rank
    assert_equal 2, @scope2.where(specimen_id: @specimen3.id).first.rank

    assert_equal 4, @scope2.where(specimen_id: @specimen1.id).first.quantity
    assert_equal 4, @scope2.where(specimen_id: @new_specimen.id).first.quantity
    assert_equal 2, @scope2.where(specimen_id: @specimen3.id).first.quantity
  end

  def test_uses_status_of_merged_to
    # specimen4 is reworking, specimen2 is normal
    @scope1.where(specimen_id: @specimen4).update_all(status: Occurrence::REWORKING)
    # specimen2 is reworking, specimen4 is normal
    @scope2.where(specimen_id: @specimen2).update_all(status: Occurrence::REWORKING)

    @merger.move(@sample1, from: @specimen4, to: @specimen2)
    @merger.move(@sample2, from: @specimen4, to: @specimen2)

    assert_equal Occurrence::NORMAL, @scope1.where(specimen_id: @specimen2.id).first.status # specimen2 stays normal
    assert_equal Occurrence::REWORKING, @scope2.where(specimen_id: @specimen2.id).first.status # specimen2 stays reworking
  end

  def test_merges_to_first_occurrence
    assert_equal 4, @scope1.count
    assert_equal 4, @scope2.count

    @merger.move(@sample1, from: @specimen4, to: @specimen2)
    @merger.move(@sample2, from: @specimen4, to: @specimen2)

    assert_equal 3, @scope1.count
    specimens = @scope1.map(&:specimen_id)
    assert specimens.include?(@specimen1.id)
    assert specimens.include?(@specimen2.id)
    assert specimens.include?(@specimen3.id)

    assert_equal 1, @scope1.where(specimen_id: @specimen1.id).first.rank
    assert_equal 2, @scope1.where(specimen_id: @specimen2.id).first.rank
    assert_equal 3, @scope1.where(specimen_id: @specimen3.id).first.rank

    assert_equal 1, @scope1.where(specimen_id: @specimen1.id).first.quantity
    assert_equal 6, @scope1.where(specimen_id: @specimen2.id).first.quantity
    assert_equal 3, @scope1.where(specimen_id: @specimen3.id).first.quantity

    assert_equal 3, @scope2.count
    specimens = @scope2.map(&:specimen_id)
    assert specimens.include?(@specimen1.id)
    assert specimens.include?(@specimen2.id)
    assert specimens.include?(@specimen3.id)

    assert_equal 4, @scope2.where(specimen_id: @specimen1.id).first.rank
    assert_equal 1, @scope2.where(specimen_id: @specimen2.id).first.rank
    assert_equal 2, @scope2.where(specimen_id: @specimen3.id).first.rank

    assert_equal 4, @scope2.where(specimen_id: @specimen1.id).first.quantity
    assert_equal 4, @scope2.where(specimen_id: @specimen2.id).first.quantity
    assert_equal 2, @scope2.where(specimen_id: @specimen3.id).first.quantity
  end
end
