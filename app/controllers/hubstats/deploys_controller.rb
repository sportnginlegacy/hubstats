require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

# I'll probably need to update the users controller, model, as well so that we can access their deploys
    def index
      @deploys = Deploy.all
    end

    def show
    end

  end
 end
