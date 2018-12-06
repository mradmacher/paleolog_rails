require 'test_helper'

class CountingTest < ActiveSupport::TestCase
  should 'build valid sham' do
    assert Counting.sham!( :build ).valid?
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

  context 'group_per_gram' do
    setup do
      section = Section.sham!
      @counting = Counting.sham! project: section.project
      @sample = Sample.sham! section: section
      @group = Group.sham!
      @marker = Specimen.sham!
      Occurrence.sham!( counting: @counting, sample: @sample, specimen: Specimen.sham!( group: @group ), quantity: 15 )
      Occurrence.sham!( counting: @counting, sample: @sample, specimen: Specimen.sham!( group: @group ), quantity: 42 )
      Occurrence.sham!( counting: @counting, sample: @sample, specimen: Specimen.sham!( group: Group.sham! ) )
      Occurrence.sham!( counting: @counting, sample: @sample, specimen: Specimen.sham!( group: Group.sham! ) )
    end

    should 'return nil when there is not enough properties' do
      @counting.group = nil
      @counting.marker = nil
      @counting.marker_count = nil
      @sample.weight = nil

      assert_nil @counting.group_per_gram( @sample )

      @counting.group = @group
      assert_nil @counting.group_per_gram( @sample )

      @counting.marker = @marker
      assert_nil @counting.group_per_gram( @sample )

      @counting.marker_count = 37
      assert_nil @counting.group_per_gram( @sample )

      @sample.weight = 4.1234
      assert_nil @counting.group_per_gram( @sample )

      Occurrence.sham!( sample: @sample, counting: @counting, specimen: @marker, quantity: 20 )

      @sample.weight = 0
      assert_nil @counting.group_per_gram( @sample )

      @sample.weight = ''
      assert_nil @counting.group_per_gram( @sample )

      @sample.weight = 4.1234
      @counting.marker_count = ''
      assert_nil @counting.group_per_gram( @sample )
    end

    should 'get proper result' do
      @counting.group = @group
      @counting.marker = @marker
      @counting.marker_count = 37
      @sample.weight = 4.1234
      Occurrence.sham!( sample: @sample, counting: @counting, specimen: @marker, quantity: 20 )
      assert_equal 25.57, @counting.group_per_gram( @sample ).round(2) #25.57
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
    end

    should 'return nil when there is not enough properties' do
      @counting.group = nil
      @counting.marker = nil
      @counting.marker_count = nil
      @sample.weight = nil
      @sample.save

      assert @counting.occurrence_density_map(@section).empty?

      @counting.group = @group
      assert @counting.occurrence_density_map(@section).empty?

      @counting.marker = @marker
      assert @counting.occurrence_density_map(@section).empty?

      @counting.marker_count = 37
      assert @counting.occurrence_density_map(@section).empty?

      @sample.weight = 4.1234
      @sample.save
      assert @counting.occurrence_density_map(@section).empty?

      Occurrence.sham!(sample: @sample, counting: @counting, specimen: @marker, quantity: 20)

      @sample.weight = 0
      @sample.save
      assert @counting.occurrence_density_map(@section).empty?

      @sample.weight = ''
      @sample.save
      assert @counting.occurrence_density_map(@section).empty?

      @sample.weight = 4.1234
      @sample.save
      @counting.marker_count = ''
      assert @counting.occurrence_density_map(@section).empty?
    end

    should 'return proper result' do
      @counting.group = @group
      @counting.marker = @marker
      @counting.marker_count = 37
      @sample.weight = 4.1234
      @sample.save

      Occurrence.sham!( sample: @sample, counting: @counting, specimen: @marker, quantity: 20 )

      density_map = @counting.occurrence_density_map(@section)
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
      [100, 200, 300, 400, 500, 600, 700].each do |depth|
        @samples << Sample.sham!( section: @section, bottom_depth: depth )
      end
      @groups = [ Group.sham!, Group.sham! ]

      @species = []
      @groups.each_with_index do |group, i|
        @species[i] = []
        4.times { @species[i] << Specimen.sham!( group: group ) }
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
        @occurrences[value[0]][value[1]] = Occurrence.sham!( counting: @counting, sample: @samples[value[0]],
          specimen: @species[value[2]][value[3]], rank: value[1],
          status: (value[2] == 0 ? Occurrence::NORMAL : Occurrence::OUTSIDE_COUNT) )
      end
    end

    context 'summary' do
      should 'return proper values' do
        expected_species = [@species[0][2], @species[0][3], @species[1][0], @species[0][1],
          @species[1][1], @species[1][2], @species[0][0]]
        expected_samples = [@samples[0], @samples[1], @samples[2], @samples[3], @samples[4], @samples[5], @samples[6]]
        expected_occurrences = [
          [ @occurrences[0][0], @occurrences[0][1], @occurrences[0][2], nil, nil, nil, nil ],
          [ @occurrences[1][1], nil, nil, @occurrences[1][0], @occurrences[1][2], @occurrences[1][3], nil],
          [ @occurrences[2][3], @occurrences[2][2], @occurrences[2][4], @occurrences[2][1], nil, nil, @occurrences[2][0] ],
          [ nil, nil, nil, nil, nil, nil, nil ],
          [ @occurrences[4][0], nil, nil, nil, nil, nil, @occurrences[4][1] ],
          [ nil, nil, @occurrences[5][3], nil, @occurrences[5][2], @occurrences[5][1], @occurrences[5][0] ],
          [ @occurrences[6][0], nil, nil, nil, nil, nil, nil ]
        ]
        samples, species, occurrences = @counting.summary(@section)
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end

=begin
      should 'return proper values for selected species with splitting groups' do
        expected_species = [@species[0][3], @species[0][1], @species[0][0], @species[1][2]]
        expected_samples = [@samples[0], @samples[1], @samples[2], @samples[3], @samples[4], @samples[5], @samples[6]]
        expected_occurrences = [
          [ @occurrences[0][1], nil, nil, nil ],
          [ nil, @occurrences[1][0], nil, @occurrences[1][3] ],
          [ @occurrences[2][2], @occurrences[2][1], @occurrences[2][0], nil ],
          [ nil, nil, nil, nil ],
          [ nil, nil, @occurrences[4][1], nil ],
          [ nil, nil, @occurrences[5][0], @occurrences[5][1] ],
          [ nil, nil, nil, nil ]
        ]
        samples, species, occurrences = @counting.summary( true, nil, [@species[0][1], @species[1][2], @species[0][3], @species[0][0]] )
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end

      should 'return proper values for selected species without splitting groups' do
        expected_species = [@species[0][3], @species[0][1], @species[1][2], @species[0][0]]
        expected_samples = [@samples[0], @samples[1], @samples[2], @samples[3], @samples[4], @samples[5], @samples[6]]
        expected_occurrences = [
          [ @occurrences[0][1], nil, nil, nil ],
          [ nil, @occurrences[1][0], @occurrences[1][3], nil ],
          [ @occurrences[2][2], @occurrences[2][1], nil, @occurrences[2][0] ],
          [ nil, nil, nil, nil ],
          [ nil, nil, nil, @occurrences[4][1] ],
          [ nil, nil, @occurrences[5][1], @occurrences[5][0] ],
          [ nil, nil, nil, nil ]
        ]
        samples, species, occurrences = @counting.summary( false, nil,
          [@species[0][1].id, @species[1][2].id, @species[0][3].id, @species[0][0].id] )
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end

      should 'return proper values for selected samples with splitting groups' do
        expected_species = [@species[0][1], @species[0][2], @species[0][0], @species[0][3],
          @species[1][1], @species[1][2], @species[1][0]]
        expected_samples = [@samples[1], @samples[2], @samples[4], @samples[6]]
        expected_occurrences = [
          [ @occurrences[1][0], @occurrences[1][1], nil, nil, @occurrences[1][2], @occurrences[1][3], nil ],
          [ @occurrences[2][1], @occurrences[2][3], @occurrences[2][0], @occurrences[2][2], nil, nil, @occurrences[2][4] ],
          [ nil, @occurrences[4][0], @occurrences[4][1], nil, nil, nil, nil ],
          [ nil, @occurrences[6][0], nil, nil, nil, nil, nil ]
        ]
        samples, species, occurrences = @counting.summary( true, [@samples[1].id, @samples[2].id, @samples[4].id, @samples[6].id] )
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end

      should 'return proper values for selected samples without splitting groups' do
        expected_species = [@species[0][1], @species[0][2], @species[1][1], @species[1][2],
          @species[0][0], @species[0][3], @species[1][0]]
        expected_samples = [@samples[1], @samples[2], @samples[4], @samples[6]]
        expected_occurrences = [
          [ @occurrences[1][0], @occurrences[1][1], @occurrences[1][2], @occurrences[1][3], nil, nil, nil ],
          [ @occurrences[2][1], @occurrences[2][3], nil, nil, @occurrences[2][0], @occurrences[2][2], @occurrences[2][4] ],
          [ nil, @occurrences[4][0], nil, nil, @occurrences[4][1], nil, nil ],
          [ nil, @occurrences[6][0], nil, nil, nil, nil, nil ]
        ]
        samples, species, occurrences = @counting.summary( false, [@samples[1].id, @samples[2].id, @samples[4].id, @samples[6].id] )
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end

      should 'return proper values with splitting groups' do
        expected_species = [@species[0][2], @species[0][3], @species[0][1], @species[0][0],
          @species[1][0], @species[1][1], @species[1][2]]
        expected_samples = [@samples[0], @samples[1], @samples[2], @samples[3], @samples[4], @samples[5], @samples[6]]
        expected_occurrences = [
          [ @occurrences[0][0], @occurrences[0][1], nil, nil, @occurrences[0][2], nil, nil ],
          [ @occurrences[1][1], nil, @occurrences[1][0], nil, nil, @occurrences[1][2], @occurrences[1][3] ],
          [ @occurrences[2][3], @occurrences[2][2], @occurrences[2][1], @occurrences[2][0], @occurrences[2][4], nil, nil ],
          [ nil, nil, nil, nil, nil, nil, nil ],
          [ @occurrences[4][0], nil, nil, @occurrences[4][1], nil, nil, nil ],
          [ nil, nil, nil, @occurrences[5][0], @occurrences[5][3], @occurrences[5][2], @occurrences[5][1] ],
          [ @occurrences[6][0], nil, nil, nil, nil, nil, nil ]
        ]
        samples, species, occurrences = @counting.summary( true )
        assert_equal expected_species, species
        assert_equal expected_samples, samples
        assert_equal expected_occurrences, occurrences
      end
=end
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
            sample_depth[depth] = Sample.sham!(section: @section, :bottom_depth => depth )
            @samples << sample_depth[depth]
          end
          Occurrence.sham!( counting: @counting, sample: sample_depth[depth],
            rank: rank, specimen: species[rank-1] )
          @testing_examples << { sample: sample_depth[depth], rank: rank, species: species[rank-1] }
        end
      end
    end

    should 'return specimens' do
      sorted = @testing_examples.sort{ |a, b|
        a[:sample].bottom_depth == b[:sample].bottom_depth ? a[:rank] <=> b[:rank] : a[:sample].bottom_depth <=> b[:sample].bottom_depth }
      expected_specimen_ids = sorted.map{ |v| v[:species].id }.uniq

      received_specimens = @counting.specimens_by_occurrence(@section.ordered_samples)
      assert_equal expected_specimen_ids.size, received_specimens.size
      assert_equal expected_specimen_ids, received_specimens.map{ |s| s.id }
    end

    should 'return specimens in sample' do
      selected_samples = @samples.sample( Random.new.rand( 1..@samples.size) )
      selected_samples = selected_samples.sort{ |a, b| a.bottom_depth <=> b.bottom_depth }
      sorted = @testing_examples.reject{ |t| !selected_samples.include?( t[:sample] ) }.sort{ |a, b|
        a[:sample].bottom_depth == b[:sample].bottom_depth ? a[:rank] <=> b[:rank] : a[:sample].bottom_depth <=> b[:sample].bottom_depth }
      expected_specimen_ids = sorted.map{ |v| v[:species].id }.uniq

      received_specimens = @counting.specimens_by_occurrence(selected_samples)
      assert_equal expected_specimen_ids.size, received_specimens.size
      assert_equal expected_specimen_ids, received_specimens.map{ |s| s.id }
    end
  end

  context 'availabe_species_ids' do
    should 'return not used species ids in given sample' do
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

      assert_equal [species2.id], counting.available_species_ids( group.id, sample.id )
    end

    should 'return all species ids for other sample' do
      group = Group.sham!
      species1 = Specimen.sham!( group: group )
      species2 = Specimen.sham!( group: group )
      species3 = Specimen.sham!( group: group )
      other_species = Specimen.sham!
      section = Section.sham!
      counting = Counting.sham!(project: section.project)
      sample = Sample.sham!(section: section)
      other_sample = Sample.sham!(section: section)
      Occurrence.sham!( counting: counting, sample: sample, specimen: species1 )
      Occurrence.sham!( counting: counting, sample: sample, specimen: species3 )

      tested = counting.available_species_ids( group.id, other_sample.id )
      assert_equal 3, tested.size
      assert tested.include? species1.id
      assert tested.include? species2.id
      assert tested.include? species3.id
    end
  end
end
