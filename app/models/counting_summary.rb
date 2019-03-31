class CountingSummary
  attr_reader :counting

  def initialize(counting)
    @counting = counting
  end

  def available_species_ids(group_id, sample_id)
    used_ids = counting.occurrences.from_sample_id(sample_id).all.collect(&:specimen_id)
    if used_ids.empty? then used_ids << 0 end
    Specimen.where(group_id: group_id).where('id not in (?)', used_ids).order(:name).pluck(:id)
  end

  def group_per_gram(sample)
    return nil unless can_compute_density?(sample)
    marker_count = counting.occurrences.from_sample(sample).where( :specimen_id => counting.marker_id ).sum( :quantity )
    return nil if marker_count == 0
    group_count = counting.occurrences.from_group(counting.group).from_sample(sample).sum( :quantity ) * 1.0
    gpg = ((group_count/marker_count)*(counting.marker_count/sample.weight))
  end

  def occurrence_density_map(section)
    density_map = {}
    section.samples.each do |sample|
      next unless can_compute_density?(sample)
      marker_cnt = counting.occurrences.from_sample(sample).where(specimen_id: counting.marker_id).sum(:quantity)
      next if marker_cnt == 0
      counting.occurrences.from_group(counting.group).from_sample(sample).each do |occ|
        density_map[occ] = ((((occ.quantity || 0)*1.0)/marker_cnt)*(counting.marker_count/sample.weight))
      end
    end
    density_map
  end

  # occurrence: in: [:first, :last]
  def summary(section, occurrence: :first)
    samples_summary = section.samples.ordered

    species_summary = specimens_by_occurrence(occurrence == :first ? samples_summary : samples_summary.reverse)

    occurrences_summary = []
    samples_summary.each_with_index do |sample, row|
      occurrences_summary[row] = []
      occrs = {}
      counting.occurrences.from_sample(sample).each { |occ| occrs[occ.specimen_id] = occ }
      species_summary.each_with_index do |sp, column|
        occurrences_summary[row][column] = occrs[sp.id]
      end
    end

    [samples_summary, species_summary, occurrences_summary]
  end

  def specimens_by_occurrence_for_section(section)
    specimens_by_occurrence(section.samples.ordered)
  end

  def specimens_by_occurrence(samples)
    specimens = []
    samples.each do |sample|
      occurrences = counting.occurrences.where(sample_id: sample.id)
      occurrences = occurrences.except_specimens(specimens).ordered_by_depth.ordered_by_occurrence
      specimens += occurrences.map(&:specimen)
    end
    specimens
  end

  private

  def can_compute_density?(sample)
    !counting.group.nil? && !counting.marker.nil? && !counting.marker_count.nil? && !sample.weight.nil? && (sample.weight != 0.0)
  end
end
