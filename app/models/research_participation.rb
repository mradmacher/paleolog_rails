class ResearchParticipation < ActiveRecord::Base
  belongs_to :region
  belongs_to :user

  validates :region_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :region_id }
  validates :manager, inclusion: { in: [true, false] }

  scope :viewable_by, lambda { |user| joins(:region).where(user_id: user.id) }
  scope :manageable_by, lambda { |user| joins(:region).where(user_id: user.id, manager: true) }

  def manageable_by?(user)
    !region.nil? && self.region.manageable_by?(user)
  end

  def viewable_by?(user)
    !region.nil? && region.viewable_by?(user)
  end
end
