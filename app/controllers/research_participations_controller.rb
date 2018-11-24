class ResearchParticipationsController < ApplicationController
	before_filter :requires_user

	def show
    @research_participation = ResearchParticipation.find(params[:id])
    raise User::NotAuthorized unless @research_participation.viewable_by?(current_user)
		@region = @research_participation.region
	end

	def new
    @region = Region.find(params[:region_id])
    raise User::NotAuthorized unless @region.manageable_by?(current_user)
    @research_participation = ResearchParticipation.new(region: @region)
    @other_users = User.where('users.id not in (?)', @region.research_participations.map{ |rc| rc.user_id })
	end

	def create
    @research_participation = ResearchParticipation.new(research_participation_params)
    raise User::NotAuthorized unless @research_participation.manageable_by?( current_user )
    if @research_participation.save
			flash[:notice] = 'User added to research.'
      redirect_to region_url(@research_participation.region)
    else
			flash[:notice] = 'User can\'t be added to research.'
      redirect_to region_url(@research_participation.region)
    end
	end

	def destroy
    @research_participation = ResearchParticipation.find(params[:id])
    raise User::NotAuthorized unless @research_participation.manageable_by?(current_user)

	  if @research_participation.destroy
			flash[:notice] = 'User removed from research.'
      redirect_to region_url(@research_participation.region)
		else
			flash[:notice] = 'User can\'t be removed from account.'
      redirect_to region_url(@research_participation.region)
		end
  end

  def research_participation_params
    params.require(:research_participation).permit(:region_id, :user_id, :manager)
  end
end
