require 'spec_helper'

module Hubstats
  describe EventsHandler, :type => :model do
    context "PullRequestEvent" do
      let(:user) {create(:user, :updated_at => Date.today)}
      let(:repo) {create(:repo, :updated_at => Date.today)}
      let(:pull) {create(:pull_request, :updated_at => Date.today, :user => user, :repo => repo)}
      let(:payload) {create(:pull_request_payload_hash)}

      subject {Hubstats::EventsHandler.new()}
      it 'should successfully route the event' do
        expect(subject).to receive(:pull_processor)
        subject.route(payload, payload[:type])
      end

      it 'should add labels to pull request' do
        payload[:github_action] = 'created'
        allow(PullRequest).to receive(:create_or_update) {pull}
        allow(Repo).to receive(:where) {[repo,repo]}
        allow(GithubAPI).to receive(:get_labels_for_pull) {[{name: 'low'}, {name: 'high'}]}
        expect(pull).to receive(:add_labels).with([{name: 'low'}, {name: 'high'}])
        subject.route(payload, payload[:type])
      end

      it 'should add new labels to pull requests' do
        payload[:github_action] = 'labeled'
        payload[:label] = {name: 'new_label'}
        allow(PullRequest).to receive(:create_or_update) {pull}
        allow(Repo).to receive(:where) {[repo,repo]}
        allow(GithubAPI).to receive(:get_labels_for_pull) {[{name: 'low'}, {name: 'high'}]}
        expect(pull).to receive(:update_label).with(payload)
        subject.route(payload, payload[:type])
      end

      it 'should remove old labels from pull requests' do
        payload[:github_action] = 'unlabeled'
        payload[:label] = {name: 'old_label'}
        allow(PullRequest).to receive(:create_or_update) {pull}
        allow(Repo).to receive(:where) {[repo,repo]}
        allow(GithubAPI).to receive(:get_labels_for_pull) {[{name: 'low'}, {name: 'high'}, {name: 'old_label'}]}
        expect(pull).to receive(:update_label).with(payload)
        subject.route(payload, payload[:type])
      end
    end

    context "CommentEvent" do
      let(:user) {create(:user, :updated_at => Date.today, :created_at => '2015-01-01', :login => "hermina", :id => 0, :role => "User")}

      it 'should successfully route the event' do
        ehandler = EventsHandler.new()
        payload = create(:comment_payload_hash)
        expect(ehandler).to receive(:comment_processor)
        ehandler.route(payload, payload[:type])
      end

      it 'should successfully process the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = create(:comment_payload_hash)
        expect(Hubstats::Comment).to receive(:create_or_update)
        ehandler.route(payload, payload[:type])
      end

      it 'should successfully creates_or_updates the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = create(:comment_payload_hash,
          :user => {:login=>"hermina", :id=>0, :role=>"User"},
          :comment => {
            "id"=>194761,
            "body"=>"Quidem ea minus ut odio optio.",
            "kind"=>"Issue",
            "user"=>{},
            "created_at" => Date.today,
            "updated_at" => Date.today
          }
        )
        allow(Hubstats::User).to receive_message_chain(:create_or_update).and_return(user)
        expect(ehandler.route(payload, payload[:type]).class).to eq(Hubstats::Comment)
      end

      it 'should successfully creates_or_updates the event even if the user is missing' do
        ehandler = Hubstats::EventsHandler.new()
        payload = create(:comment_payload_hash,
          :user => {:login=>"hermina", :id=>0, :role=>"User"},
          :comment => {
            "id"=>194761,
            "body"=>"Quidem ea minus ut odio optio.",
            "kind"=>"Issue",
            "user"=>nil,
            "created_at" => Date.today,
            "updated_at" => Date.today
          }
        )
        allow(Hubstats::User).to receive_message_chain(:create_or_update).and_return(user)
        expect(ehandler.route(payload, payload[:type])).to be_nil
      end
    end

    context "TeamEvent" do
      it 'should successfully route the team' do
        ehandler = EventsHandler.new()
        payload = create(:team_payload_hash)
        expect(ehandler).to receive(:team_processor)
        ehandler.route(payload, payload[:type])
      end

      it 'should successfully process the team' do
        ehandler = Hubstats::EventsHandler.new()
        payload = create(:team_payload_hash)
        user = create(:user)
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("team_list") { ["Team One", "Team Two", "Team Three"] }
        allow(payload).to receive(:[]).with(:event).and_return(payload)
        allow(payload).to receive(:[]).with(:team).and_return({:name => "Team One"})
        allow(payload).to receive(:[]).with(:member).and_return(user)
        allow(payload).to receive(:[]).with(:github_action).and_return("added")
        allow(payload).to receive(:[]).with(:scope).and_return("team")
        allow(payload).to receive(:[]).with(:action).and_return("added")
        allow(Hubstats::User).to receive(:create_or_update).and_return(user)
        expect(Hubstats::Team).to receive(:create_or_update)
        expect(Hubstats::Team).to receive(:update_users_in_team)
        ehandler.route(payload, "MembershipEvent")
      end

      it 'should successfully create_or_update the team' do
        ehandler = Hubstats::EventsHandler.new()
        payload = create(:team_payload_hash)
        team = create(:team)
        user = create(:user)
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("team_list") { ["Team One", "Team Two", "Team Three"] }
        allow(Hubstats::User).to receive(:create_or_update).and_return(user)
        allow(payload).to receive(:[]).with(:event).and_return(payload)
        allow(payload).to receive(:[]).with(:team).and_return({:name => "Team One"})
        allow(payload).to receive(:[]).with(:member).and_return(user)
        allow(payload).to receive(:[]).with(:github_action).and_return("added")
        allow(payload).to receive(:[]).with(:scope).and_return("team")
        allow(payload).to receive(:[]).with(:action).and_return("added")
        expect(Hubstats::Team).to receive(:update_users_in_team)
        expect(Hubstats::Team).to receive(:create_or_update).and_return(team)
        ehandler.route(payload, "MembershipEvent")
      end
    end

  end
end
