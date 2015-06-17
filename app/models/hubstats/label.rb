module Hubstats
  class Label < ActiveRecord::Base

  scope :with_a_pull_request, lambda { |params, timespan|
    select("hubstats_labels.*")
    .select("COUNT(hubstats_labels_pull_requests.pull_request_id) AS pull_request_count")
    .joins(:pull_requests).merge(Hubstats::PullRequest.filter_based_on_timespan(timespan, params[:state])
                                                      .belonging_to_users(params[:users])
                                                      .belonging_to_repos(params[:repos]))
    .having("pull_request_count > 0")
    .group("hubstats_labels.id")
  }

    scope :with_ids, lambda { |pull_ids| (where("hubstats_labels_pull_requests.pull_request_id" => pull_ids)) }

    scope :with_state, lambda {|state| (where(state: state) unless state == 'all') if state}

    attr_accessible :url, :name, :color

    has_and_belongs_to_many :pull_requests, :join_table => 'hubstats_labels_pull_requests'

    def self.first_or_create(label)
      if exists = Hubstats::Label.where(name: label[:name]).first
        return exists
      else
        Label.new(name: label[:name], url: label[:url], color: label[:color])
      end
    end

  end
end
