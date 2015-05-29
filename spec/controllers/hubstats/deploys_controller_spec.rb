require 'spec_helper'

module Hubstats
  RSpec.describe DeploysController, :type => :controller do
    describe "#create" do
      it 'should create a deploy' do
        @deploy = build(:deploy)
        expect(@deploy).to be_an_instance_of Deploy
        expect(response).to have_http_status(200)
      end
    end

    describe "#create" do
      it 'should NOT create a deploy' do
        deploy = build(:bad_deploy)
        expect(@deploy).not_to be_an_instance_of Deploy
      end
    end
  end
end
