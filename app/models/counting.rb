class Counting < ActiveRecord::Base
  NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

  belongs_to :project
  belongs_to :group
  belongs_to :marker, :class_name => 'Specimen'
  has_many :occurrences

	validates :name, presence: true, uniqueness: { scope: :project_id }, length: { within: NAME_RANGE }
	validates :project_id, presence: true
  validates :marker_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  before_destroy do
    unless self.can_be_destroyed?
      errors[:base] << I18n.t( 'activerecord.errors.models.counting.occurrences.exist' )
      false
    end
  end

  scope :viewable_by, lambda { |user| joins(project: :research_participations).where(research_participations: { user_id: user.id }) }
  scope :manageable_by, lambda { |user| joins(project: :research_participations).where(research_participations: { user_id: user.id, manager: true }) }

  def manageable_by?(user)
    !project.nil? && project.manageable_by?(user)
  end

  def viewable_by?(user)
    !project.nil? && project.viewable_by?(user)
  end

  def can_be_destroyed?
    !self.occurrences.exists?
  end
end
