require 'spec_helper'

describe Hubstats
  context ".config" do
    subject { Hubstats }
    after do
      Hubstats.class_variable_set(:@@config, nil)
    end
    it "creates a new config object" do
      expect(Hubstats::Config).to receive(:parse).at_least(:once) { double(:config) }
      subject.config
    end

    it "memorizes the config object" do
      expect(Hubstats::Config).to receive(:parse).at_least(:once) { double(:config) }
      subject.config
      subject.config
    end

  end
