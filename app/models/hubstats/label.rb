module Hubstats
  class Label < ActiveRecord::Base
    scope :with_number_of_pulls, lambda {
      select("hubstats_labels.*")
      .select("COUNT(hubstats_labels_pull_requests.pull_request_id) AS pull_request_count")
      .joins("LEFT JOIN hubstats_labels_pull_requests ON hubstats_labels_pull_requests.label_id = hubstats_labels.id")
      .group("hubstats_labels.id")
    }

    attr_accessible :url, :name, :color

    has_and_belongs_to_many :pull_requests, :join_table => 'hubstats_labels_pull_requests'
  end
end
