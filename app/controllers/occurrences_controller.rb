class OccurrencesController < ApplicationController
	before_filter :requires_user

  def available
    @counting = Counting.viewable_by(current_user).find(params[:counting_id])
    respond_to do |format|
      format.json do
		    render json: Specimen.where( id: @counting.available_species_ids(params[:group_id], params[:sample_id])).order(:name)
      end
    end
  end

  def index
    @counting = Counting.viewable_by(current_user).find(params[:counting_id])
    @sample = Sample.find(params[:sample_id])
    @section = @sample.section
    @project = @section.project
    @occurrences = Occurrence.where(counting_id: params[:counting_id], sample_id: params[:sample_id])
  end

	def count
    @counting = Counting.viewable_by(current_user).find(params[:counting_id])
    raise User::NotAuthorized unless @counting.manageable_by? current_user
    @sample = Sample.find( params[:sample_id] )
    @section = @sample.section
    @project = @section.project
    @occurrences = Occurrence.where( sample_id: @sample.id, counting_id: @counting.id ).ordered_by_occurrence
		@occurrence = Occurrence.new( sample: @sample, counting: @counting )
	end

	def set_uncertain
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by(current_user).find(occurrence_id)
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.uncertain = params[:quantity]
    @occurrence.save
    respond_to do |format|
      format.json do
		    render json: {
          'occurrence_id' => occurrence_id,
          'quantity' => @occurrence.uncertain?
        }
      end
    end
	end

	def set_status
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by(current_user).find(occurrence_id)
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.status = params[:quantity].to_i
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample( @occurrence.sample )
    respond_to do |format|
      format.json do
		    render json: {
          'occurrence_id' => occurrence_id,
          'quantity' => @occurrence.status,
          'countable' => @occurrences.countable.sum(:quantity),
          'uncountable' => @occurrences.uncountable.sum(:quantity)
        }
      end
    end
	end

	def set_quantity
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by( current_user ).find(occurrence_id)
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.quantity = params[:quantity].to_i
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample(@occurrence.sample)
    respond_to do |format|
      format.json do
		    render json: {
          'occurrence_id' => occurrence_id,
          'quantity' => @occurrence.quantity,
          'countable' => @occurrences.countable.sum(:quantity),
          'uncountable' => @occurrences.uncountable.sum(:quantity)
        }
      end
    end
	end

  def increase_quantity
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by(current_user).find(occurrence_id)
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.quantity = 0 if @occurrence.quantity.nil?
    @occurrence.quantity += 1
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample(@occurrence.sample)
    respond_to do |format|
      format.json do
        render json: {
          'occurrence_id' => occurrence_id,
          'quantity' => @occurrence.quantity,
          'countable' => @occurrences.countable.sum(:quantity),
          'uncountable' => @occurrences.uncountable.sum(:quantity)
        }
      end
    end
  end

  def decrease_quantity
    occurrence_id = params[:id]
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by(current_user).find(occurrence_id)
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.quantity = 0 unless !@occurrence.quantity.nil?
    @occurrence.quantity = @occurrence.quantity == 0 ? nil : @occurrence.quantity - 1
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample( @occurrence.sample )
    respond_to do |format|
      format.json do
        render json: {
          'occurrence_id' => occurrence_id,
          'quantity' => @occurrence.quantity,
          'countable' => @occurrences.countable.sum(:quantity),
          'uncountable' => @occurrences.uncountable.sum(:quantity)
        }
      end
    end
  end

  def exchange
    ocr1 = Occurrence.viewable_by(current_user).find(params[:id1])
    ocr2 = Occurrence.viewable_by(current_user).find(params[:id2])
    raise User::NotAuthorized unless ocr1.manageable_by? current_user
    raise User::NotAuthorized unless ocr2.manageable_by? current_user
    rank1 = ocr1.rank
    rank2 = ocr2.rank
    Occurrence.transaction do
      ocr1.update_attribute(:rank, rank2)
      ocr2.update_attribute(:rank, rank1)
    end
    respond_to do |format|
      format.json do
        render json: {}
      end
    end
  end

  def create
    @occurrence = Occurrence.new(occurrence_params)
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    max = Occurrence.where(counting_id: @occurrence.counting_id, sample_id: @occurrence.sample_id).maximum( :rank )
    @occurrence.rank = max.nil? ? 0 : max + 1
    @occurrence.save
		redirect_to edit_counting_sample_occurrences_url( @occurrence.counting_id, @occurrence.sample_id )
  end

  def update
    @occurrence = Occurrence.viewable_by( current_user ).find(params[:id])
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.assign_attributes(occurrence_params)
    @occurrence.save
		redirect_to edit_counting_sample_occurrences_url( @occurrence.counting, @occurrence.sample )
  end

  def destroy
    @occurrence = Occurrence.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.destroy

		redirect_to edit_counting_sample_occurrences_url( @occurrence.counting, @occurrence.sample )
  end

  def occurrence_params
    params.require(:occurrence).permit(
      :specimen_id,
      :specimen_type,
      :quantity,
      :sample_counting_id,
      :rank,
      :status,
      :uncertain,
      :sample_id,
      :counting_id
    )
  end
end
