require 'test_helper'

class CountingSummaryTest < ActiveSupport::TestCase
  context 'group_per_gram' do
    setup do
      section = Section.sham!
      @counting = Counting.sham!(project: section.project)
      @sample = Sample.sham!(section: section)
      @group = Group.sham!
      @marker = Specimen.sham!
      Occurrence.sham!(counting: @counting, sample: @sample, specimen: Specimen.sham!( group: @group ), quantity: 15)
      Occurrence.sham!(counting: @counting, sample: @sample, specimen: Specimen.sham!( group: @group ), quantity: 42)
      Occurrence.sham!(counting: @counting, sample: @sample, specimen: Specimen.sham!( group: Group.sham! ))
      Occurrence.sham!(counting: @counting, sample: @sample, specimen: Specimen.sham!( group: Group.sham! ))
      @summary = CountingSummary.new(@counting)
    end

    should 'return nil when there is not enough properties' do
      @counting.group = nil
      @counting.marker = nil
      @counting.marker_count = nil
      @sample.weight = nil

      assert_nil @summary.group_per_gram(@sample)

      @counting.group = @group
      assert_nil @summary.group_per_gram(@sample)

      @counting.marker = @marker
      assert_nil @summary.group_per_gram(@sample)

      @counting.marker_count = 37
      assert_nil @summary.group_per_gram(@sample)

      @sample.weight = 4.1234
      assert_nil @summary.group_per_gram(@sample)

      Occurrence.sham!(sample: @sample, counting: @counting, specimen: @marker, quantity: 20)

      @sample.weight = 0
      assert_nil @summary.group_per_gram(@sample)

      @sample.weight = ''
      assert_nil @summary.group_per_gram(@sample)

      @sample.weight = 4.1234
      @counting.marker_count = ''
      assert_nil @summary.group_per_gram(@sample)
    end

    should 'get proper result' do
      @counting.group = @group
      @counting.marker = @marker
      @counting.marker_count = 37
      @sample.weight = 4.1234
      Occurrence.sham!(sample: @sample, counting: @counting, specimen: @marker, quantity: 20)
      assert_equal 25.57, @summary.group_per_gram( @sample ).round(2) #25.57
    end
  end

  context 'occurrence_density_map' do
    setup do
      @section = Section.sham!
      @counting = Counting.sham!(project: @section.project)
      @sample = Sample.sham!(section: @section)
      @group = Group.sham!
      @marker = Specimen.sham!
      @specimen15 = Specimen.sham!(group: @group)
      @specimen41 = Specimen.sham!(group: @group)
      @specimennil = Specimen.sham!(group: @group)

      @occurrence15 = Occurrence.sham!(sample: @sample, counting: @counting, specimen: @specimen15, quantity: 15)
      @occurrence41 = Occurrence.sham!(sample: @sample, counting: @counting, specimen: @specimen41, quantity: 41)
      @occurrencenil = Occurrence.sham!(sample: @sample, counting: @counting, specimen: @specimennil, quantity: nil)
      Occurrence.sham!(sample: @sample, counting: @counting, specimen: Specimen.sham!(group: Group.sham!) )
      Occurrence.sham!(sample: @sample, counting: @counting, specimen: Specimen.sham!(group: Group.sham!) )
      @summary = CountingSummary.new(@counting)
    end

    should 'return nil when there is not enough properties' do
      @counting.group = nil
      @counting.marker = nil
      @counting.marker_count = nil
      @sample.weight = nil
      @sample.save

      assert @summary.occurrence_density_map(@section).empty?

      @counting.group = @group
      assert @summary.occurrence_density_map(@section).empty?

      @counting.marker = @marker
      assert @summary.occurrence_density_map(@section).empty?

      @counting.marker_count = 37
      assert @summary.occurrence_density_map(@section).empty?

      @sample.weight = 4.1234
      @sample.save
      assert @summary.occurrence_density_map(@section).empty?

      Occurrence.sham!(sample: @sample, counting: @counting, specimen: @marker, quantity: 20)

      @sample.weight = 0
      @sample.save
      assert @summary.occurrence_density_map(@section).empty?

      @sample.weight = ''
      @sample.save
      assert @summary.occurrence_density_map(@section).empty?

      @sample.weight = 4.1234
      @sample.save
      @counting.marker_count = ''
      assert @summary.occurrence_density_map(@section).empty?
    end

    should 'return proper result' do
      @counting.group = @group
      @counting.marker = @marker
      @counting.marker_count = 37
      @sample.weight = 4.1234
      @sample.save

      Occurrence.sham!(sample: @sample, counting: @counting, specimen: @marker, quantity: 20)

      density_map = @summary.occurrence_density_map(@section)
      refute density_map.empty?
      assert_equal 3, density_map.keys.size
      assert_equal 7, density_map[@occurrence15].round
      assert_equal 18, density_map[@occurrence41].round
      assert_equal 0, density_map[@occurrencenil]
    end
  end

  context 'for samples/species/occurrences' do
    setup do
      @section = Section.sham!
      @counting = Counting.sham!(project: @section.project)
      @samples = []
      %w(100 200 300 400 500 600 700).each_with_index do |name, rank|
        @samples << Sample.sham!(section: @section, name: name, rank: rank)
      end
      @groups = [Group.sham!, Group.sham!]

      @species = []
      @groups.each_with_index do |group, i|
        @species[i] = []
        4.times { @species[i] << Specimen.sham!(group: group) }
      end

      @occurrences = []
      #sample, rank, group, species
      [
        [0, 0, 0, 2], [0, 1, 0, 3], [0, 2, 1, 0],
        [1, 0, 0, 1], [1, 1, 0, 2], [1, 2, 1, 1], [1, 3, 1, 2],
        [2, 0, 0, 0], [2, 1, 0, 1], [2, 2, 0, 3], [2, 3, 0, 2], [2, 4, 1, 0],
        [4, 0, 0, 2], [4, 1, 0, 0],
        [5, 0, 0, 0], [5, 1, 1, 2], [5, 2, 1, 1], [5, 3, 1, 0],
        [6, 0, 0, 2]
      ].each do |value|
        @occurrences[value[0]] = [] if @occurrences[value[0]].nil?
        @occurrences[value[0]][value[1]] = Occurrence.sham!(
          counting: @counting,
          sample: @samples[value[0]],
          specimen: @species[value[2]][value[3]],
          rank: value[1],
          status: (value[2] == 0 ? Occurrence::NORMAL : Occurrence::OUTSIDE_COUNT)
        )
      end
      @summary = CountingSummary.new(@counting)
    end

    context 'summary' do
      should 'return proper values for last occurrence' do
        expected_species = [@species[0][2], @species[0][0], @species[1][2], @species[1][1],
          @species[1][0], @species[0][1], @species[0][3]]
        expected_samples = [@samples[0], @samples[1], @samples[2], @samples[3], @samples[4], @samples[5], @samples[6]]
        expected_occurrences = [
          [@occurrences[0][0], nil, nil, nil, @occurrences[0][2], nil, @occurrences[0][1]],
          [@occurrences[1][1], nil, @occurrences[1][3], @occurrences[1][2], nil, @occurrences[1][0], nil],
          [@occurrences[2][3], @occurrences[2][0], nil, nil, @occurrences[2][4], @occurrences[2][1], @occurrences[2][2]],
          [nil, nil, nil, nil, nil, nil, nil],
          [@occurrences[4][0], @occurrences[4][1], nil, nil, nil, nil, nil],
          [nil, @occurrences[5][0], @occurrences[5][1], @occurrences[5][2], @occurrences[5][3], nil, nil],
          [@occurrences[6][0], nil, nil, nil, nil, nil, nil],
        ]
        samples, species, occurrences = @summary.summary(@section, occurrence: :last)
        assert_equal expected_species, species
        assert_equal expected_samples, samples

        assert_equal expected_occurrences, occurrences
      end

      should 'return proper values for first occurrence' do
        expected_species = [@species[0][2], @species[0][3], @species[1][0], @species[0][1],
          @species[1][1], @species[1][2], @species[0][0]]
        expected_samples = [@samples[0], @samples[1], @samples[2], @samples[3], @samples[4], @samples[5], @samples[6]]
        expected_occurrences = [
          [@occurrences[0][0], @occurrences[0][1], @occurrences[0][2], nil, nil, nil, nil],
          [@occurrences[1][1], nil, nil, @occurrences[1][0], @occurrences[1][2], @occurrences[1][3], nil],
          [@occurrences[2][3], @occurrences[2][2], @occurrences[2][4], @occurrences[2][1], nil, nil, @occurrences[2][0]],
          [nil, nil, nil, nil, nil, nil, nil],
          [@occurrences[4][0], nil, nil, nil, nil, nil, @occurrences[4][1]],
          [nil, nil, @occurrences[5][3], nil, @occurrences[5][2], @occurrences[5][1], @occurrences[5][0]],
          [@occurrences[6][0], nil, nil, nil, nil, nil, nil]
        ]
        samples, species, occurrences = @summary.summary(@section, occurrence: :first)
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end
    end
  end

  context 'specimens_by_occurrence' do
    setup do
      @section = Section.sham!
      @counting = Counting.sham!(project: @section.project)

      sample_depth = {}
      @samples = []
      specimens = []
      @groups = []
      @testing_examples = []
      3.times { @groups << Group.sham! }
      80.times { specimens << Specimen.sham!( group: @groups.sample( 1 ).first ) }
      (1..10).to_a.each do |depth|
        species = specimens.sample( Random.new.rand( 1..specimens.size ) )
        (1..species.size).to_a.each do |rank|
          unless sample_depth.keys.include?( depth )
            sample_depth[depth] = Sample.sham!(section: @section, rank: depth )
            @samples << sample_depth[depth]
          end
          Occurrence.sham!( counting: @counting, sample: sample_depth[depth],
            rank: rank, specimen: species[rank-1] )
          @testing_examples << { sample: sample_depth[depth], rank: rank, species: species[rank-1] }
        end
      end
      @summary = CountingSummary.new(@counting)
    end

    should 'return ordered specimens' do
      sorted = @testing_examples.sort do |a, b|
        a[:sample].rank == b[:sample].rank ? a[:rank] <=> b[:rank] : a[:sample].rank <=> b[:sample].rank
      end
      expected_specimen_ids = sorted.map { |v| v[:species].id }.uniq

      received_specimens = @summary.specimens_by_occurrence_for_section(@section)
      assert_equal expected_specimen_ids.size, received_specimens.size
      assert_equal expected_specimen_ids, received_specimens.map{ |s| s.id }
    end

    should 'return specimens in sample' do
      selected_samples = @samples.sample( Random.new.rand( 1..@samples.size) )
      selected_samples = selected_samples.sort{ |a, b| a.rank <=> b.rank }
      sorted = @testing_examples.reject{ |t| !selected_samples.include?( t[:sample] ) }.sort{ |a, b|
        a[:sample].rank == b[:sample].rank ? a[:rank] <=> b[:rank] : a[:sample].rank <=> b[:sample].rank }
      expected_specimen_ids = sorted.map{ |v| v[:species].id }.uniq

      received_specimens = @summary.specimens_by_occurrence(selected_samples)
      assert_equal expected_specimen_ids.size, received_specimens.size
      assert_equal expected_specimen_ids, received_specimens.map{ |s| s.id }
    end
  end

  context 'availabe_species_ids' do
    should 'returns not used species ids in given sample' do
      group = Group.sham!
      species1 = Specimen.sham!( group: group )
      species2 = Specimen.sham!( group: group )
      species3 = Specimen.sham!( group: group )
      other_species = Specimen.sham!
      section = Section.sham!
      counting = Counting.sham!(project: section.project)
      sample = Sample.sham!(section: section)
      Occurrence.sham!(counting: counting, sample: sample, specimen: species1)
      Occurrence.sham!(counting: counting, sample: sample, specimen: species3)

      assert_equal [species2.id], CountingSummary.new(counting).available_species_ids( group.id, sample.id )
    end

    should 'returns all species ids for other sample' do
      group = Group.sham!
      species1 = Specimen.sham!( group: group )
      species2 = Specimen.sham!( group: group )
      species3 = Specimen.sham!( group: group )
      other_species = Specimen.sham!
      section = Section.sham!
      counting = Counting.sham!(project: section.project)
      sample = Sample.sham!(section: section)
      other_sample = Sample.sham!(section: section)
      Occurrence.sham!(counting: counting, sample: sample, specimen: species1)
      Occurrence.sham!(counting: counting, sample: sample, specimen: species3)

      tested = CountingSummary.new(counting).available_species_ids(group.id, other_sample.id)
      assert_equal 3, tested.size
      assert tested.include? species1.id
      assert tested.include? species2.id
      assert tested.include? species3.id
    end
  end
end
