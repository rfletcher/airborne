require 'rest_client'

module Airborne
  module RestClientRequester
    def make_request( method, url, opts = {} )
      default_opts    = Airborne.configuration.opts || {}
      default_headers = Airborne.configuration.headers || {}
      default_params  = Airborne.configuration.params || {}

      opts    = default_opts.merge( opts )

      body    = opts.delete( :body )
      headers = default_headers.merge( opts.delete( :headers ) || {} )
      params  = default_params.merge( opts.delete( :params ) || {} )

      # pass params as the body, or as a query string?
      if [:post, :patch, :put, :delete].include?( method )
        body = params if body.nil?
      else
        headers[:params] = params
      end

      # convert a body hash to JSON, for convenience
      if body.is_a?( Hash ) && !headers[:content_type].nil? && headers[:content_type].match( /json/ )
        body = body.to_json
      end

      opts.merge!(
        :headers => headers,
        :method  => method,
        :payload => body,
        :url     => get_url( url ),
      )

      begin
        RestClient::Request.execute( opts )
      rescue RestClient::Exception => e
        e.response
      end
    end

    private

    def base_headers
      { content_type: :json }.merge(Airborne.configuration.headers || {})
    end
  end
end
