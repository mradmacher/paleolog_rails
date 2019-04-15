class CountingMerge
  attr_reader :counting

  def initialize(counting)
    @counting = counting
  end

  def move(sample, from: , to: )
    scope = Occurrence.where(counting_id: counting.id, sample_id: sample.id)
    first_other_occurrence = scope.where(specimen_id: from.id).order(rank: :asc).first
    return unless first_other_occurrence

    first_occurrence = scope.where(specimen_id: to.id).order(rank: :asc).first
    if first_occurrence
      if first_occurrence.quantity.nil? && first_other_occurrence.quantity.nil?
        first_occurrence.quantity = nil
      else
        first_occurrence.quantity = (first_occurrence.quantity || 0) + (first_other_occurrence.quantity || 0)
      end
      if first_other_occurrence.rank < first_occurrence.rank
        first_occurrence.rank = first_other_occurrence.rank
      end
      Occurrence.transaction do
        first_other_occurrence.destroy
        first_occurrence.save
      end
    else
      first_other_occurrence.update(specimen_id: to.id)
    end
  end
end
