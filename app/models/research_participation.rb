class ResearchParticipation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates :project_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :project_id }
  validates :manager, inclusion: { in: [true, false] }

  scope :viewable_by, lambda { |user| joins(:project).where(user_id: user.id) }
  scope :manageable_by, lambda { |user| joins(:project).where(user_id: user.id, manager: true) }

  def manageable_by?(user)
    !project.nil? && self.project.manageable_by?(user)
  end

  def viewable_by?(user)
    !project.nil? && project.viewable_by?(user)
  end
end
