require 'spec_helper'

module Hubstats
  describe EventsHandler, :type => :model do
    context "PullRequestEvent" do
      let(:pull) {build(:pull_request)}
      let(:repo) {build(:repo)}
      let(:payload) {build(:pull_request_payload_hash)}

      it 'successfully routes the event' do
        ehandler = Hubstats::EventsHandler.new()
        expect(ehandler).to receive(:pull_processor)
        ehandler.route(payload,payload[:type])
      end

      it 'adds labels to pull request' do
        ehandler = Hubstats::EventsHandler.new()
        allow(Hubstats::PullRequest).to receive(:create_or_update) {pull}
        allow(Hubstats::Repo).to receive(:where) {[repo,repo]}
        allow(Hubstats::GithubAPI).to receive(:get_labels) {['low','high']}
        expect(pull).to receive(:add_labels).with(['low','high'])
        ehandler.route(payload,payload[:type])
      end
    end

    # context "CommentEvent" do
    #   it 'successfully routes the event' do
    #     ehandler = Hubstats::EventsHandler.new()
    #     payload = build(:comment_payload_hash)
    #     expect(ehandler).to receive(:comment_processor)

    #     ehandler.route(payload,payload[:type])
    #   end

    #   it 'successfully processes the event' do
    #     ehandler = Hubstats::EventsHandler.new()
    #     payload = build(:comment_payload_hash)
    #     expect(Hubstats::Comment).to receive(:create_or_update)

    #     ehandler.route(payload,payload[:type])
    #   end

    #   it 'successfully creates_or_updates the event' do
    #     ehandler = Hubstats::EventsHandler.new()
    #     payload = build(:comment_payload_hash)
    #     expect(ehandler.route(payload,payload[:type]).class).to eq(Hubstats::Comment)
    #   end
    # end

  end
end