require 'spec_helper'

describe Hubstats
  context ".config" do
    it "creates a new config object" do
      expect(Hubstats::Config).to receive(:parse).once
      Hubstats.config
    end

    it "memoizes the config object" do
      expect(Hubstats::Config).to receive(:parse).once { double(:config) }
      Hubstats.config
      Hubstats.config
    end

  end
