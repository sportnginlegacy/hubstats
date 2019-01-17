require 'spec_helper'

module Hubstats
  describe PullRequestsController, :type => :controller do
    routes { Hubstats::Engine.routes }

    describe "#index" do
      it "should correctly order all of the pull requests" do
        user = create(:user, :updated_at => '2015-12-01')
        repo = create(:repo, :updated_at => '2015-12-01')
        pull3 = create(:pull_request, :user => user,
                                      :repo => repo,
                                      :updated_at => '2015-05-30')
        pull1 = create(:pull_request, :user => user,
                                      :repo => repo,
                                      :updated_at => '2015-05-30')
        pull4 = create(:pull_request, :user => user,
                                      :repo => repo,
                                      :updated_at => '2015-05-30')
        pull2 = create(:pull_request, :user => user,
                                      :repo => repo,
                                      :updated_at => '2015-05-30')
        pulls_ordered = [pull3, pull1, pull4, pull2]
        expect(Hubstats::PullRequest).to receive_message_chain("group_by.with_label.state_based_order.paginate").and_return(pulls_ordered)
        get :index
        expect(response).to have_http_status(200)
        expect(response).to render_template(:index)
      end
    end

    describe "#show" do
      it "should show the comments and deploy of specific pull request" do
        user = create(:user, :updated_at => '2015-12-01')
        repo = create(:repo, :updated_at => '2015-12-01')
        pull = create(:pull_request, :user => user,
                                     :repo => repo,
                                     :deploy_id => 404040,
                                     :updated_at => '2015-05-30')
        comment1 = create(:comment, :pull_request_id => pull.id, :created_at => Date.today, :updated_at => '2015-12-01', user: user)
        comment2 = create(:comment, :pull_request_id => pull.id, :created_at => Date.today, :updated_at => '2015-12-01', user: user)
        comment3 = create(:comment, :pull_request_id => pull.id, :created_at => Date.today, :updated_at => '2015-12-01', user: user)
        get :show, repo: repo, id: pull.id
        expect(assigns(:pull_request)).to eq(pull)
        expect(assigns(:pull_request).repo_id).to eq(101010)
        expect(assigns(:pull_request).deploy_id).to eq(404040)
        expect(assigns(:comments)).to contain_exactly(comment1, comment2, comment3)
        expect(assigns(:pull_request).user_id).to eq(user.id)
      end
    end
  end
end
