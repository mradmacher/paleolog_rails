#TODO counting and sample should have the same well
class Sample < ActiveRecord::Base
  NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

  NAME_SIZE = 10
  BOTTOM_DEPTH_SIZE = 10
  TOP_DEPTH_SIZE = 10
  WEIGHT_SIZE = 10
	DESCRIPTION_ROWS = 12
	DESCRIPTION_COLS = 60

  belongs_to :well
  has_many :images
  has_many :occurrences

  validates :name, :uniqueness => { :scope => :well_id }, :presence => true, :length => { :within => NAME_RANGE }
  validates :well_id, :presence => true
  validates :weight, :numericality => { :greater_than => 0 }, :allow_nil => true

  default_scope -> { order(:bottom_depth) }

  scope :viewable_by, lambda { |user| joins( :well ).joins( :well => :research_participations ).where(
    :research_participations => { user_id: user.id } ) }
  scope :manageable_by, lambda { |user| joins( :well ).joins( :well => :research_participations ).where(
    :research_participations => { user_id: user.id, manager: true } ) }

  def manageable_by?( user )
    !self.well.nil? && self.well.research_participations.where( user_id: user.id, manager: true ).exists?
  end

  def viewable_by?( user )
    !self.well.nil? && self.well.research_participations.where( user_id: user.id ).exists?
  end

  def full_name
    "#{well.name} : #{name}"
  end

  def can_be_destroyed?
    !self.occurrences.exists?
  end

  before_destroy do
    if can_be_destroyed?
      self.occurrences.destroy_all
    else
      errors[:base] << I18n.t( 'activerecord.errors.models.sample.occurrences.exist' )
      false
    end
  end
end
