require_dependency "hubstats/application_controller"

module Hubstats
  class TeamsController < Hubstats::BaseController

    def index
      # if params[:query]
      #   @teams = Hubstats::Team.where("name LIKE ?", "%#{params[:query]}%").order("name ASC")
      # elsif params[:id]
      #   @teams = Hubstats::Team.where(id: params[:id].split(",")).order("name ASC")
      # else
      @teams = Hubstats::Team.with_id(params[:teams])
          .paginate(:page => params[:page], :per_page => 15)
      # end
      
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @teams}
      end
    end

    def show
      @team = Hubstats::Team.where(name: params[:team]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_team(@team.id).merged_in_date_range(@start_date, @end_date).order("updated_at DESC").limit(20)
      @pull_count = Hubstats::PullRequest.belonging_to_team(@team.id).merged_in_date_range(@start_date, @end_date).count(:all)
      @comment_count = Hubstats::Comment.belonging_to_team(@team.id).created_in_date_range(@start_date, @end_date).count(:all)
      @users = Hubstats::User.team(@team.id)
      @user_count = Hubstats::User.team(@team.id).length
      @net_additions = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).belonging_to_team(@team.id).sum(:additions).to_i -
                       Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).belonging_to_team(@team.id).sum(:deletions).to_i
      @additions = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).belonging_to_team(@team.id).average(:additions)
      @deletions = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).belonging_to_team(@team.id).average(:deletions)      

      stats
    end

    # stats
    # Will assign all of the stats for both the show page and the dashboard page.
    def stats
      @additions ||= 0
      @deletions ||= 0
      @stats_basics = {
        user_count: @user_count,
        pull_count: @pull_count,
        comment_count: @comment_count
      }
      @stats_additions = {
        avg_additions: @additions.round.to_i,
        avg_deletions: @deletions.round.to_i,
        net_additions: @net_additions
      }
    end
  end
end
