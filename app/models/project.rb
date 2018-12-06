class Project < ActiveRecord::Base
	has_many :sections

	NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH
  NAME_SIZE = 20

	has_many :countings, { :dependent => :destroy }, -> { order(:name) }
  has_many :research_participations, :dependent => :destroy

	validates :name, :presence => true, :length => { :within => NAME_RANGE }
  validates :name, :uniqueness => true

  scope :viewable_by, lambda { |user| joins(:research_participations).where(research_participations: { user_id: user.id }) }
  scope :manageable_by, lambda { |user| joins(:research_participations).where(research_participations: { user_id: user.id, manager: true }) }

  before_destroy do
    unless self.sections.empty?
      errors[:base] << I18n.t('activerecord.errors.models.project.sections.exist')
      false
    end
  end

  def manageable_by?(user)
    research_participations.where(user_id: user.id, manager: true).exists?
  end

  def viewable_by?( user )
    research_participations.where(user_id: user.id).exists?
  end

end
