module Hubstats
  class Label < ActiveRecord::Base
    attr_accessible :url, :name, :color

    has_and_belongs_to_many :pull_requests, :join_table => 'hubstats_labels_pull_requests'
  end
end
