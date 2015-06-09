require 'spec_helper'

module Hubstats
  describe Label, :type => :model do
    it 'should create a label' do
      label_hash = {name: "Feature request",
                    color: "FCEC7F",
                    url: "https://api.github.com/repos/sportngin/ngin/labels/feature-request"}
      label = Label.create(label_hash)
      expect(Label.count).to eq(1)
      expect(label.name).to eq("Feature request")
      expect(label.color).to eq("FCEC7F")
      expect(label.url).to eq("https://api.github.com/repos/sportngin/ngin/labels/feature-request")
    end
  end
end
