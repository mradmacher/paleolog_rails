require 'test_helper'

class SpecimenTest < ActiveSupport::TestCase
  def test_if_sham_builds_valid_object
    assert Specimen.sham!( :build ).valid?
  end

  def test_if_invalid_when_name_length_less_than_min
    specimen = Specimen.sham!( :build, :name => 'a' * (Specimen::NAME_MIN_LENGTH - 1) )
    refute specimen.valid?
		assert specimen.invalid?( :name )
		assert specimen.errors[:name].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.name.too_short', 
      :count => Specimen::NAME_MIN_LENGTH ) )
  end

  def test_if_valid_when_name_length_equals_min
    specimen = Specimen.sham!( :build, :name => 'a' * Specimen::NAME_MIN_LENGTH )
    assert specimen.valid?
	end

  def test_if_invalid_when_name_length_greater_than_max
    specimen = Specimen.sham!( :build, :name => 'a' * (Specimen::NAME_MAX_LENGTH + 1) )
    refute specimen.valid?
		assert specimen.invalid?( :name )
		assert specimen.errors[:name].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.name.too_long', 
      :count => Specimen::NAME_MAX_LENGTH ) )
  end

  def test_if_valid_when_name_longth_equals_max
    specimen = Specimen.sham!( :build, :name => 'a' * Specimen::NAME_MAX_LENGTH )
    assert specimen.valid?
	end

  def test_if_invalid_when_description_max_length_exceeded
    specimen = Specimen.sham!( :build, :description => 'a' * (Specimen::DESCRIPTION_MAX_LENGTH + 1) )
    refute specimen.valid?
		assert specimen.invalid?( :description )
		assert specimen.errors[:description].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.description.too_long',
      :count => Specimen::DESCRIPTION_MAX_LENGTH ) )
	end

  def test_if_invalid_when_age_maximum_length_exceeded
    specimen = Specimen.sham!( :build, :age => 'a' * (Specimen::AGE_MAX_LENGTH + 1) )
    refute specimen.valid?
		assert specimen.invalid?( :age )
		assert specimen.errors[:age].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.age.too_long',
      :count => Specimen::AGE_MAX_LENGTH ) )
	end

  def test_if_invalid_when_comparison_maximum_length_exceeded
    specimen = Specimen.sham!( :build, :comparison => 'a' * (Specimen::COMPARISON_MAX_LENGTH + 1) )
    refute specimen.valid?
		assert specimen.invalid?( :comparison )
		assert specimen.errors[:comparison].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.comparison.too_long',
      :count => Specimen::COMPARISON_MAX_LENGTH ) )
	end

  def test_if_invalid_when_range_maximum_length_exceeded
    specimen = Specimen.sham!( :build, :range => 'a' * (Specimen::RANGE_MAX_LENGTH + 1) )
    refute specimen.valid?
		assert specimen.invalid?( :range )
		assert specimen.errors[:range].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.range.too_long',
      :count => Specimen::RANGE_MAX_LENGTH ) )
	end

  def test_name_uniqueness_in_group
    existing = Specimen.sham!
    specimen = Specimen.sham!( :build, :group => existing.group, :name => existing.name )
    refute specimen.valid?
		assert specimen.errors[:name].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.name.taken' ) )
  end

  def test_name_not_have_to_be_unique_in_different_groups
    existing = Specimen.sham!
    specimen = Specimen.sham!( :group => Group.sham!, :name => existing.name )
    assert specimen.valid?
	end

  def test_if_invalid_when_group_not_present
    specimen = Specimen.sham!( :build )
    specimen.group = nil
    refute specimen.valid?
    assert specimen.invalid?( :group_id )
		assert specimen.errors[:group_id].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.group_id.blank' ) )
  end

  should 'destroy dependent features after destroying when has some features' do
    group = Group.sham!
    field = Field.sham!( group: group )
    choice = Choice.sham!( field: field )
    specimen = Specimen.sham!( group: group )
    feature = Feature.sham!( choice: choice, specimen: specimen )

    assert Feature.where( id: feature.id ).exists?
    specimen.destroy
    refute Feature.where( id: feature.id ).exists?
  end

  should 'not allow to change group when has some features' do
    group = Group.sham!
    other_group = Group.sham!
    field = Field.sham!( group: group )
    choice = Choice.sham!( field: field )
    specimen = Specimen.sham!( group: group )
    feature = Feature.sham!( choice: choice, specimen: specimen )

    specimen.group = other_group
    refute specimen.valid?
		assert specimen.errors[:group_id].include?( I18n.t( 'activerecord.errors.models.specimen.attributes.group_id.features' ) )
  end

  context 'search' do
    context 'group' do
      setup do
        @group1 = Group.sham!
        @group2 = Group.sham!
        @species1 = [Specimen.sham!( group: @group1 ), Specimen.sham!( group: @group1 ), Specimen.sham!( group: @group1 )]
        @species2 = [Specimen.sham!( group: @group2 ), Specimen.sham!( group: @group2 ), Specimen.sham!( group: @group2 )]
      end

      should 'return all for nil filter' do
        result = Specimen.search
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'blank all for blank filter' do
        result = Specimen.search( group_id: '' )
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return only for given group' do
        result = Specimen.search( group_id: @group1.id )
        assert_equal @species1.size, result.size
        @species1.each do |species|
          assert result.include?( species )
        end
      end
    end

    context 'counting' do
      setup do
        @counting1 = Counting.sham!
        @counting2 = Counting.sham!

        @species11 = Specimen.sham!
        @species12 = Specimen.sham!
        @species21 = Specimen.sham!
        @species22 = Specimen.sham!

        Occurrence.sham!( counting: @counting1, sample: Sample.sham!( well: @counting1.well ), specimen: @species11 )
        Occurrence.sham!( counting: @counting1, sample: Sample.sham!( well: @counting1.well ), specimen: @species12 )
        @species1 = [@species11, @species12]
        Occurrence.sham!( counting: @counting2, sample: Sample.sham!( well: @counting2.well ), specimen: @species21 ) 
        Occurrence.sham!( counting: @counting2, sample: Sample.sham!( well: @counting2.well ), specimen: @species22 )
        @species2 = [@species21, @species22]
      end

      should 'return all for nil filter' do
        result = Specimen.search
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return all for blank filter' do
        result = Specimen.search( counting_id: '' )
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return only for given counting' do
        result = Specimen.search( counting_id: @counting1.id )
        assert_equal @species1.size, result.size
        @species1.each do |species|
          assert result.include?( species )
        end
      end
    end

    context 'choice_id' do
      setup do
        @group = Group.sham!
        @field = Field.sham!( group: @group )
        @choice1 = Choice.sham!( field: @field )
        @choice2 = Choice.sham!( field: @field )

        @other_field = Field.sham!( group: @group )
        @other_choice1 = Choice.sham!( field: @other_field )
        @other_choice2 = Choice.sham!( field: @other_field )

        @species11 = Specimen.sham!( group: @group )
        @species12 = Specimen.sham!( group: @group )
        Feature.sham!( choice: @choice1, specimen: @species11 ) 
        Feature.sham!( choice: @choice1, specimen: @species12 ) 
        Feature.sham!( choice: @other_choice1, specimen: @species11 ) 

        @species21 = Specimen.sham!( group: @group )
        @species22 = Specimen.sham!( group: @group )
        Feature.sham!( choice: @choice2, specimen: @species21 ) 
        Feature.sham!( choice: @choice2, specimen: @species22 ) 

        @species1 = [@species11, @species12]
        @species2 = [@species21, @species22]
      end

      should 'return all for nil filter' do
        result = Specimen.search
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return all for blank filter' do
        result = Specimen.search( choice_id: '' )
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return only for given choice' do
        result = Specimen.search( choice_id: @choice1.id )
        assert_equal @species1.size, result.size
        @species1.each do |species|
          assert result.include?( species )
        end
      end

    end

    context 'choice_ids' do
      setup do
        @group = Group.sham!
        @field = Field.sham!( group: @group )
        @choice1 = Choice.sham!( field: @field )
        @choice2 = Choice.sham!( field: @field )

        @other_field = Field.sham!( group: @group )
        @other_choice1 = Choice.sham!( field: @other_field )
        @other_choice2 = Choice.sham!( field: @other_field )

        @species11 = Specimen.sham!( group: @group )
        @species12 = Specimen.sham!( group: @group )
        Feature.sham!( choice: @choice1, specimen: @species11 ) 
        Feature.sham!( choice: @choice1, specimen: @species12 ) 
        Feature.sham!( choice: @other_choice1, specimen: @species11 ) 

        @species21 = Specimen.sham!( group: @group )
        @species22 = Specimen.sham!( group: @group )
        Feature.sham!( choice: @choice2, specimen: @species21 ) 
        Feature.sham!( choice: @choice2, specimen: @species22 ) 

        @species1 = [@species11, @species12]
        @species2 = [@species21, @species22]
      end

      should 'return all for nil filter' do
        result = Specimen.search
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return all for blank filter' do
        result = Specimen.search( choice_ids: '' )
        assert_equal @species1.size + @species2.size, result.size
        (@species1 + @species2).each do |species|
          assert result.include?( species )
        end
      end

      should 'return only for given choice' do
        result = Specimen.search( choice_id: @choice1.id )
        assert_equal @species1.size, result.size
        @species1.each do |species|
          assert result.include?( species )
        end
      end

      should 'treat one choice in multiple choices as single choice' do
        multi_result = Specimen.search( choice_ids: [@choice1.id] )
        single_result = Specimen.search( choice_id: @choice1.id )
        assert_equal single_result.size, multi_result.size
        single_result.each do |s|
          assert multi_result.include?( s )
        end
      end

      should 'respect multiple choices' do
        result = Specimen.search( choice_ids: [@choice1.id, @other_choice1.id] )
        assert_equal 1, result.size
        assert result.include?( @species11 )
      end

      should 'ignore blank choices' do
        result = Specimen.search( choice_ids: ['', @choice1.id, '', @other_choice1.id] )
        assert_equal 1, result.size
        assert result.include?( @species11 )
      end
    end

  end

end
