require_dependency "hubstats/application_controller"

module Hubstats
  class EventsController < ApplicationController

    def handler
      verify_signature(request)

      kind = request.headers["X-Github-Event"]
      event = params.with_indifferent_access
      eventsHandler = Hubstats::EventsHandler.new()
      eventsHandler.route(event,kind)

      render :nothing => true
    end

    private
    def verify_signature(request)
      request.body.rewind
      payload_body = request.body.read
      signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), Hubstats.config.webhook_endpoint, payload_body)
      return 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env["HTTP_X_HUB_SIGNATURE"])
    end
  end
end
