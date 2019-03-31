class Section < ActiveRecord::Base
  NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

  has_many :samples
  has_many :users, :through => :research_participations
  belongs_to :project

  validates :name, presence: true, length: { within: NAME_RANGE }, uniqueness: { scope: :project_id }
  validates :project_id, presence: true

  scope :viewable_by, lambda { |user| joins(project: :research_participations).where(research_participations: { user_id: user.id }) }
  scope :manageable_by, lambda { |user| joins(project: :research_participations).where(research_participations: { user_id: user.id, manager: true }) }

  before_destroy do
    unless self.samples.empty?
      errors[:base] << I18n.t('activerecord.errors.models.section.samples.exist')
      false
    end
  end

  def manageable_by?(user)
    !self.project.nil? && self.project.research_participations.where(user_id: user.id, manager: true).exists?
  end

  def viewable_by?(user)
    !self.project.nil? && self.project.research_participations.where(user_id: user.id).exists?
  end

  def managers
    self.users.where(research_participations: { manager: true } )
  end
end
