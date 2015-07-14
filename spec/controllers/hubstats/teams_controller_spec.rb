require 'spec_helper'

module Hubstats
  describe TeamsController, :type => :controller do
    routes { Hubstats::Engine.routes }
    describe "#index" do
      it "should return true" do
        expect(true).to eq(true)
      end
    end

    describe "#show" do
      it "should return true" do
        expect(true).to eq(true)
      end
    end
  end
end
