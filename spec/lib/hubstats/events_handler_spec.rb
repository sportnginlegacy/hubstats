require 'spec_helper'

module Hubstats
  describe EventsHandler, :type => :model do
    context "PullRequestEvent" do
      it 'successfully routes the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = build(:pull_request_payload_hash)
        expect(ehandler).to receive(:pull_processor)

        ehandler.route(payload,payload[:type])
      end

      it 'successfully processes the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = build(:pull_request_payload_hash)
        expect(Hubstats::PullRequest).to receive(:create_or_update)

        ehandler.route(payload,payload[:type])
      end

      it 'successfully creates_or_updates the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = build(:pull_request_payload_hash)
        expect(ehandler.route(payload,payload[:type]).class).to eq(Hubstats::PullRequest)
      end
    end

    context "CommentEvent" do
      it 'successfully routes the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = build(:comment_payload_hash)
        expect(ehandler).to receive(:comment_processor)

        ehandler.route(payload,payload[:type])
      end

      it 'successfully processes the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = build(:comment_payload_hash)
        expect(Hubstats::Comment).to receive(:create_or_update)

        ehandler.route(payload,payload[:type])
      end

      it 'successfully creates_or_updates the event' do
        ehandler = Hubstats::EventsHandler.new()
        payload = build(:comment_payload_hash)
        expect(ehandler.route(payload,payload[:type]).class).to eq(Hubstats::Comment)
      end
    end

  end
end