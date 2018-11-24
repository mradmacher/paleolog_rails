class Well < ActiveRecord::Base
  NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

  has_many :samples, -> { order(:bottom_depth) }
  has_many :users, :through => :research_participations
  belongs_to :region

  validates :name, :presence => true, :length => { :within => NAME_RANGE }, :uniqueness => { :scope => :region_id }
  validates :region_id, :presence => true

  scope :viewable_by, lambda { |user| joins(region: :research_participations).where(research_participations: { user_id: user.id }) }
  scope :manageable_by, lambda { |user| joins(region: :research_participations).where(research_participations: { user_id: user.id, manager: true }) }

  before_destroy do
    unless self.samples.empty?
      errors[:base] << I18n.t( 'activerecord.errors.models.well.samples.exist' )
      false
    end
  end

  def manageable_by?(user)
    !self.region.nil? && self.region.research_participations.where(user_id: user.id, manager: true).exists?
  end

  def viewable_by?(user)
    !self.region.nil? && self.region.research_participations.where(user_id: user.id).exists?
  end

  def ordered_samples
    samples.order(:bottom_depth)
  end

  def managers
    self.users.where( :research_participations => { :manager => true } )
  end
end
