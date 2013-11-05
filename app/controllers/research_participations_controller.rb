class ResearchParticipationsController < ApplicationController
	before_filter :requires_user 

  def index
    @well = Well.find( params[:well_id] )
    raise User::NotAuthorized unless @well.viewable_by?( current_user )
    @research_participations = @well.research_participations
    @other_users = User.where( 'users.id not in (?)', @research_participations.map{ |rc| rc.user_id } )
  end

	def create
    @research_participation = ResearchParticipation.new( params[:research_participation] )
    raise User::NotAuthorized unless @research_participation.manageable_by?( current_user )
    if @research_participation.save
			flash[:notice] = 'User added to research.'
      redirect_to well_research_participations_url( @research_participation.well )
    else
			flash[:notice] = 'User can\'t be added to research.'
      redirect_to well_research_participations_url( @research_participation.well )
    end
	end

	def destroy
    @research_participation = ResearchParticipation.find( params[:id] )
    raise User::NotAuthorized unless @research_participation.manageable_by?( current_user )

	  if @research_participation.destroy
			flash[:notice] = 'User removed from research.'
      redirect_to well_research_participations_url( @research_participation.well )
		else
			flash[:notice] = 'User can\'t be removed from account.'
      redirect_to well_research_participations_url( @research_participation.well )
		end
  end

end

