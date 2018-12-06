class Occurrence < ActiveRecord::Base
  belongs_to :specimen
  belongs_to :counting
  belongs_to :sample

	NORMAL = 0
	OUTSIDE_COUNT = 1
	CARVING = 2
	REWORKING = 3
	DEFAULT_STATUS = NORMAL

	STATUSES = { NORMAL => '', OUTSIDE_COUNT => '+', CARVING => 'c', REWORKING => 'r' }
	UNCERTAIN_SYMBOL = '?'

  validates :rank, presence: true, uniqueness: { scope: [:sample_id, :counting_id] }
  validates :specimen_id, presence: true, uniqueness: { scope: [:sample_id, :counting_id] }
  validates :counting_id, presence: true
  validates :sample_id, presence: true
	validates :status, presence: true, inclusion: { in: [NORMAL, OUTSIDE_COUNT, CARVING, REWORKING] }
  validate :counting_and_sample_from_same_region

  default_scope -> { order(:rank) }
	scope :countable, -> { where('status = ?', NORMAL) }
	scope :uncountable, -> { where('status <> ?', NORMAL) }
  scope :except_specimens, lambda{ |specimens| specimens.empty? ? all : where( 'specimen_id not in (?)', specimens.map{ |s| s.id } ) }
  scope :from_group, lambda{ |group| joins( :specimen ).where( :specimens => { :group_id => group.id } ) }
  scope :from_sample, lambda{ |sample| where( :sample_id => sample.id ) }
  scope :from_sample_id, lambda{ |sample_id| where( :sample_id => sample_id ) }
  scope :ordered_by_occurrence, -> { order(:rank) }
  scope :ordered_by_depth, -> { joins(:sample).order('samples.bottom_depth') }

  scope :viewable_by, lambda { |user| joins(sample: { section: { region: :research_participations }} ).where(research_participations: { user_id: user.id }) }
  scope :manageable_by, lambda { |user| joins(sample: { section: { region: :research_participations }} ).where(research_participations: { user_id: user.id, manager: true }) }

  def manageable_by?( user )
    !sample.nil? && sample.manageable_by?(user)
  end

  def viewable_by?( user )
    !sample.nil? && sample.viewable_by?(user)
  end

	def status? stat
		self.status == stat
	end

  def normal?
    self.status == NORMAL
  end
  def carving?
    self.status == CARVING
  end
  def reworking?
    self.status == REWORKING
  end
  def outside_count?
    self.status == OUTSIDE_COUNT
  end

	def status_symbol
		STATUSES[self.status]
	end

  private

  def counting_and_sample_from_same_region
    self.errors[:sample_id] << I18n.t('activerecord.errors.models.occurrence.attributes.sample_id.invalid') if
      self.counting && self.sample && self.counting.region_id != self.sample.section.region_id
  end
end
