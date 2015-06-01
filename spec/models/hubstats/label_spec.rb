require 'spec_helper'

module Hubstats
  describe Label, :type => :model do
    it 'should create a label' do
      label_hash = {name: "Feature request",
                    color: "FCEC7F",
                    url: "https://api.github.com/repos/sportngin/ngin/labels/feature-request"}
      label = Label.create(label_hash)
      expect(Label.count).to eq(1)
      expect(label.name).to eq(label_hash[:name])
      expect(label.color).to eq(label_hash[:color])
      expect(label.url).to eq(label_hash[:url])
    end
  end
end
