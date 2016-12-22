require_dependency "hubstats/application_controller"

module Hubstats
  class QaSignoffsController < Hubstats::BaseController

    # Public - Will list all of the QA Signoffs that belong to any specific user(s)
    #
    # Returns - the QA Signoff data
    def index
      @qa_signoffs = Hubstats::QaSignoff.includes(:repo, :pull_request, :user)
        .belonging_to_users(params[:users])
        .belonging_to_repos(params[:repos])
        .group_by(params[:group])
        .paginate(:page => params[:page], :per_page => 15)

      grouping(params[:group], @qa_signoffs)
    end 

    # Public - Will show the particular QA Signoff selected
    #
    # Returns - the specific details of the QA Signoff
    def show
      @repo = Hubstats::Repo.where(id: params[:repo_id]).first
      @pull_request = Hubstats::PullRequest.where(id: params[:pull_request_id]).first
      @user = Hubstats::User.where(id: params[:user_id]).first
    end
  end
end
