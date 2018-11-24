require 'test_helper'

class ResearchParticipationTest < ActiveSupport::TestCase
  def test_if_sham_is_valid
    assert ResearchParticipation.sham!( :build ).valid?
  end

  def test_it_should_have_user
    research_participation = ResearchParticipation.sham!(:build, user: nil)
    refute research_participation.valid?
		assert research_participation.errors[:user_id].include?(
      I18n.t( 'activerecord.errors.models.research_participation.attributes.user_id.blank' ) )
  end

  def test_it_should_have_region
    research_participation = ResearchParticipation.sham!(:build, region: nil)
    refute research_participation.valid?
		assert research_participation.errors[:region_id].include?(
      I18n.t( 'activerecord.errors.models.research_participation.attributes.region_id.blank' ) )
  end

  def test_it_has_set_if_manager
    research_participation = ResearchParticipation.sham!(:build, manager: nil)
    refute research_participation.valid?
		assert research_participation.errors[:manager].include?(
      I18n.t( 'activerecord.errors.models.research_participation.attributes.manager.inclusion' ) )
  end

  def test_if_user_unique_in_region
    existing = ResearchParticipation.sham!
    research_participation = ResearchParticipation.sham!(:build, user: existing.user, region: existing.region)
    refute research_participation.valid?
		assert research_participation.errors[:user_id].include?(
      I18n.t( 'activerecord.errors.models.research_participation.attributes.user_id.taken' ) )
  end
end
