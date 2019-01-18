require_dependency "hubstats/application_controller"

module Hubstats
  class EventsController < ApplicationController

    # Public - Verifies that the request we're receiving is a new event, and then will handle it and route
    # it to the correct place.
    #
    # request - the request of the new event
    #
    # Returns - nothing, but makes a new event
    def handler
      verify_signature(request)
      kind = request.headers['X-Github-Event']
      event = event_params.with_indifferent_access
      raw_parameters = request.request_parameters
      event[:github_action] = raw_parameters["action"]
      eventsHandler = Hubstats::EventsHandler.new()
      eventsHandler.route(event, kind)

      render :nothing => true
    end

    # Public - Will check that the request passed is a valid signature.
    #
    # request - the signature to be checked
    #
    # Returns - an error if the signatures don't match
    private def verify_signature(request)
      request.body.rewind
      payload_body = request.body.read
      signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), Hubstats.config.webhook_endpoint, payload_body)
      return 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    end

    # Private - Allows only these parameters to be added when creating an event
    #
    # Returns - hash of parameters
    private def event_params
      params.permit!
    end
  end
end
