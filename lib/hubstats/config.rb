require "date" # necessary to get the Date.today convenience method
require "yaml"

module Hubstats
  class Config
    def initialize(attributes={})
      assign attributes
    end

    def github_auth
      @github_auth
    end

    def github_config
      @github_config
    end

    def webhook_secret
      @webhook_secret
    end

    def webhook_endpoint
      @webhook_endpoint
    end

    def self.parse
      new(attributes_from_file)
    end

    def self.attributes_from_file
      YAML.load_file("#{Rails.root}/config/octokit.yml")
    end

    def assign(attributes)
      attributes.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
    end
  end
end