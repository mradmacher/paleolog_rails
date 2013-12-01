class Counting < ActiveRecord::Base
  NAME_MIN_LENGTH = 1
	NAME_MAX_LENGTH = 32
	NAME_RANGE = NAME_MIN_LENGTH..NAME_MAX_LENGTH

	belongs_to :well
  belongs_to :group
  belongs_to :marker, :class_name => 'Specimen'
  has_many :occurrences

	validates :name, :presence => true, :uniqueness => {:scope => :well_id}, :length => { :within => NAME_RANGE }
	validates :well_id, :presence => true
  validates :marker_count, :numericality => {:only_integer => true, :greater_than => 0 }, :allow_nil => true

  before_destroy do
    unless self.can_be_destroyed?
      errors[:base] << I18n.t( 'activerecord.errors.models.counting.occurrences.exist' )
      return false 
    end
  end

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

  def can_be_destroyed?
    !self.occurrences.exists?
  end

  def available_species_ids( group_id, sample_id )
    used_ids = self.occurrences.find( :all ).collect{ |x| x.specimen_id }
    if used_ids.empty? then used_ids << 0 end
    Specimen.where( group_id: group_id ).where( 'id not in (?)', used_ids ).order( :name ).pluck( :id )
  end

  def group_per_gram( sample )
    return nil unless can_compute_density?( sample )
    marker_count = self.occurrences.from_sample( sample ).where( :specimen_id => self.marker_id ).sum( :quantity )
    return nil if marker_count == 0
    group_count = self.occurrences.from_group( self.group ).from_sample( sample ).sum( :quantity ) * 1.0
    gpg = ((group_count/marker_count)*(self.marker_count/sample.weight))
  end

  def occurrence_density_map
    density_map = {}
    self.well.samples.each do |sample|
      next unless can_compute_density?( sample )
      marker_cnt = self.occurrences.from_sample( sample ).where( :specimen_id => self.marker_id ).sum( :quantity )
      next if marker_cnt == 0
      self.occurrences.from_group( self.group ).from_sample( sample ).each do |occ|
        density_map[occ] = ((((occ.quantity || 0)*1.0)/marker_cnt)*(self.marker_count/sample.weight))
      end
    end
    density_map
  end

  def summary
    samples_summary = self.well.samples.order( :bottom_depth )

    species_summary = []
    species_summary = specimens_by_occurrence( samples_summary )
    
    occurrences_summary = []
    samples_summary.each_with_index do |sample, row|
      occurrences_summary[row] = []
      occrs = {} 
      self.occurrences.from_sample( sample ).each{ |occ| occrs[occ.specimen_id] = occ }
      species_summary.each_with_index do |sp, column|
        occurrences_summary[row][column] = occrs[sp.id]
      end
    end

    [samples_summary, species_summary, occurrences_summary]
  end

  def specimens_by_occurrence( samples = nil )
    samples = self.well.samples.order( 'bottom_depth' ) if samples.nil?
    specimens = []
    #order of samples is important
    #samples must be ordered by bottom_depth
    #occurrences must be ordered by specimen's first occurrence
    #samples.sort{ |s1, s2| s1.bottom_depth <=> s2.bottom_depth }.each do |sample|
    samples.each do |sample|
      occurrences = self.occurrences.where( sample_id: sample.id )
      occurrences = occurrences.except_specimens( specimens ).ordered_by_depth.ordered_by_occurrence
      specimens += occurrences.map { |o| o.specimen }
    end
    specimens
  end

  private
  def can_compute_density?( sample )
    if self.group.nil? || self.marker.nil? || self.marker_count.nil? || sample.weight.nil? || sample.weight == 0.0
      false
    else
      true
    end
  end
end
