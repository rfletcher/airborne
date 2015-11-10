require 'json'
require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'

module Airborne
  class InvalidJsonError < StandardError; end

  include RequestExpectations
  include JsonpParser

  attr_reader :response, :headers, :body

  def self.configure
    RSpec.configure do |config|
      yield config
    end
  end

  def self.included(base)
    if !Airborne.configuration.requester_module.nil?
      base.send(:include, Airborne.configuration.requester_module)
    elsif !Airborne.configuration.rack_app.nil?
      base.send(:include, RackTestRequester)
    else
      base.send(:include, RestClientRequester)
    end
  end

  def self.configuration
    RSpec.configuration
  end

  def get(url, opts = {})
    @response = make_request(:get, url, opts)
  end

  def post(url, opts = {})
    @response = make_request(:post, url, opts)
  end

  def patch(url,opts = {})
    @response = make_request(:patch, url, opts)
  end

  def put(url, opts = {})
    @response = make_request(:put, url, opts)
  end

  def delete(url, opts = {})
    @response = make_request(:delete, url, opts)
  end

  def head(url, opts = {})
    @response = make_request(:head, url, opts)
  end

  def options(url, opts = {})
    @response = make_request(:options, url, opts)
  end

  def response
    @response
  end

  def headers
    HashWithIndifferentAccess.new(response.headers)
  end

  def body
    response.body
  end

  def json_body
    JSON.parse(response.body, symbolize_names: true) rescue fail InvalidJsonError, 'Api request returned invalid json'
  end

  private

  def get_url(url)
    base = Airborne.configuration.base_url || ''
    base + url
  end
end
