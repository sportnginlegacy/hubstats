require 'spec_helper'

describe Hubstats
  context ".config" do
    subject { Hubstats }
    before do
      Hubstats.remove_class_variable(:@@config)
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
