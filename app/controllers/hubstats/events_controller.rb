require_dependency "hubstats/application_controller"

module Hubstats
  class EventsController < ApplicationController

    def handler
      kind = request.headers['X-Github-Event']
      event = params.with_indifferent_access

      eventsHandler = Hubstats::EventsHandler.new()
      eventsHandler.route(event,kind)

      render :nothing => true
    end

  end
end
