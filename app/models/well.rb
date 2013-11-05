class Well < ActiveRecord::Base
  NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

  has_many :samples, :order => :bottom_depth
	has_many :countings, :dependent => :destroy, :order => :name
  has_many :users, :through => :research_participations
  has_many :research_participations, :dependent => :destroy
  belongs_to :region

  validates :name, :presence => true, :length => { :within => NAME_RANGE }, :uniqueness => { :scope => :region_id }
  validates :region_id, :presence => true

  before_destroy do
    unless self.samples.empty?
      errors[:base] << I18n.t( 'activerecord.errors.models.well.samples.exist' )
      return false 
    end
  end

  scope :viewable_by, lambda { |user| joins( :research_participations ).where( 
    :research_participations => { user_id: user.id } ) }
  scope :manageable_by, lambda { |user| joins( :research_participations ).where( 
    :research_participations => { user_id: user.id, manager: true } ) }

  def manageable_by?( user )
    self.research_participations.where( user_id: user.id, manager: true ).exists?
  end

  def viewable_by?( user )
    self.research_participations.where( user_id: user.id ).exists?
  end

  def managers
    self.users.where( :research_participations => { :manager => true } )
  end
end
