class ResearchParticipation < ActiveRecord::Base
  belongs_to :well
  belongs_to :user

  validates :well_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :well_id }
  validates :manager, :inclusion => { :in => [true, false] }

  #scope :viewable_by, lambda { |user| joins( :well ).joins( :well => :research_participations ).where( 
  #  :research_participations => { user_id: user.id } ) }
  #scope :manageable_by, lambda { |user| joins( :well ).joins( :well => :research_participations ).where( 
  #  :research_participations => { user_id: user.id, manager: true } ) }

  def in_account?( account )
    !self.well.nil? && self.well.in_account?( account )
  end

  def manageable_by?( user )
    !self.well.nil? && self.well.research_participations.where( user_id: user.id, manager: true ).exists?
  end

  def viewable_by?( user )
    !self.well.nil? && self.well.research_participations.where( user_id: user.id ).exists?
  end

end

