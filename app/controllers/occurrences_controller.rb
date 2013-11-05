class OccurrencesController < ApplicationController
	before_filter :requires_user 

	respond_to :json, :only => [:exchange, :increase_quantity, :decrease_quantity, :set_quantity, :set_status,
		:set_uncertain, :available]

  def available
    @counting = Counting.viewable_by( current_user ).find( params[:counting_id] )
    respond_with Specimen.where( id: @counting.available_species_ids( params[:group_id], params[:sample_id] ) ).order(:name)
  end

  def index
    @counting = Counting.viewable_by( current_user).find( params[:counting_id] )
    @sample = Sample.find( params[:sample_id] )
    @occurrences = Occurrence.where( counting_id: params[:counting_id], sample_id: params[:sample_id] )
  end

	def count
    @counting = Counting.viewable_by( current_user ).find( params[:counting_id] )
    raise User::NotAuthorized unless @counting.manageable_by? current_user
    @sample = Sample.find( params[:sample_id] )
    @occurrences = Occurrence.where( sample_id: @sample.id, counting_id: @counting.id ).ordered_by_occurrence
		@occurrence = Occurrence.new( sample: @sample, counting: @counting )
	end

	def set_uncertain
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by( current_user ).find( occurrence_id, readonly: false )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.uncertain = params[:quantity]
    @occurrence.save
		respond_with( { 'occurrence_id' => occurrence_id, 'quantity' => @occurrence.uncertain? } ) 
	end
	def set_status
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by( current_user ).find( occurrence_id, readonly: false )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.status = params[:quantity].to_i
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample( @occurrence.sample )
		respond_with( { 'occurrence_id' => occurrence_id, 'quantity' => @occurrence.status, 
			'countable' => @occurrences.countable.sum( :quantity ),
			'uncountable' => @occurrences.uncountable.sum( :quantity ) } )
	end

	def set_quantity
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by( current_user ).find( occurrence_id, readonly: false )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.quantity = params[:quantity].to_i
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample( @occurrence.sample )
		respond_with( { 'occurrence_id' => occurrence_id, 'quantity' => @occurrence.quantity, 
			'countable' => @occurrences.countable.sum( :quantity ),
			'uncountable' => @occurrences.uncountable.sum( :quantity ) } )
	end

  def increase_quantity
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by( current_user ).find( occurrence_id, readonly: false )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.quantity = 0 if @occurrence.quantity.nil? 
    @occurrence.quantity += 1
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample( @occurrence.sample )
		respond_with( { 'occurrence_id' => occurrence_id, 'quantity' => @occurrence.quantity, 
			'countable' => @occurrences.countable.sum( :quantity ),
			'uncountable' => @occurrences.uncountable.sum( :quantity ) } )
  end

  def decrease_quantity
    occurrence_id = params[:id]
    occurrence_id = params[:id]
    @occurrence = Occurrence.viewable_by( current_user ).find( occurrence_id, readonly: false )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.quantity = 0 unless !@occurrence.quantity.nil? 
    @occurrence.quantity = @occurrence.quantity == 0 ? nil : @occurrence.quantity - 1
    @occurrence.save
    @occurrences = @occurrence.counting.occurrences.from_sample( @occurrence.sample )
		respond_with( { 'occurrence_id' => occurrence_id, 'quantity' => @occurrence.quantity, 
			'countable' => @occurrences.countable.sum( :quantity ),
			'uncountable' => @occurrences.uncountable.sum( :quantity ) } )
  end

  def exchange
    ocr1 = Occurrence.viewable_by( current_user ).find( params[:id1], readonly: false )
    ocr2 = Occurrence.viewable_by( current_user ).find( params[:id2], readonly: false )
    raise User::NotAuthorized unless ocr1.manageable_by? current_user
    raise User::NotAuthorized unless ocr2.manageable_by? current_user
    rank1 = ocr1.rank
    rank2 = ocr2.rank
    Occurrence.transaction do
      ocr1.update_attribute( :rank, rank2 )
      ocr2.update_attribute( :rank, rank1 )
    end
    respond_with( nil )
  end

  def create
    @occurrence = Occurrence.new( params[:occurrence] )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    max = Occurrence.where( counting_id: @occurrence.counting_id, sample_id: @occurrence.sample_id ).maximum( :rank ) 
    @occurrence.rank = max.nil? ? 0 : max + 1
    @occurrence.save
		redirect_to edit_counting_sample_occurrences_url( @occurrence.counting_id, @occurrence.sample_id )
  end

  def update
    @occurrence = Occurrence.viewable_by( current_user ).find( params[:id], readonly: false )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.assign_attributes( params[:occurrence] )
    @occurrence.save

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @occurrence = Occurrence.viewable_by( current_user ).find( params[:id] )
    raise User::NotAuthorized unless @occurrence.manageable_by? current_user
    @occurrence.destroy

		redirect_to edit_counting_sample_occurrences_url( @occurrence.counting, @occurrence.sample )
  end
end

