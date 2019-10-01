require_dependency "hubstats/application_controller"

module Hubstats
  class QaSignoffsController < Hubstats::BaseController

    # Public - Will list all of the QA Signoffs that belong to any specific user(s)
    #
    # Returns - the QA Signoff data
    def index
      index_params = params.permit(:users, :repos, :group, :page)
      @qa_signoffs = Hubstats::QaSignoff.includes(:repo, :pull_request, :user)
        .belonging_to_users(index_params[:users])
        .belonging_to_repos(index_params[:repos])
        .group_by(index_params[:group])
        .paginate(:page => index_params[:page], :per_page => 15)

      grouping(index_params[:group], @qa_signoffs)
    end

    # Public - Will show the particular QA Signoff selected
    #
    # Returns - the specific details of the QA Signoff
    def show
      show_params = params.permit(:repo_id, :user_id, :pull_request_id)
      @repo = Hubstats::Repo.where(id: show_params[:repo_id]).first
      @pull_request = Hubstats::PullRequest.where(id: show_params[:pull_request_id]).first
      @user = Hubstats::User.where(id: show_params[:user_id]).first
    end
  end
end
