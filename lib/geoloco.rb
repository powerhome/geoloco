# frozen_string_literal: true

require 'httparty'

require 'geoloco/version'
require 'geoloco/location'
require 'geoloco/geometry'
require 'geoloco/adapters/tomtom'
require 'geoloco/adapters/google'

# Geoloco is a multi-adpater geolocation gem, with error
# handling and test stubs
module Geoloco
  # Top level Geoloco's error class
  class Error < StandardError; end

  # Error when an unknown adapter is given
  class UnknownAdapter < Error; end

  # Forbidden error class. Raised by adapters when a forbidden
  # error is received from the providers
  class Forbidden < Geoloco::Error
    def initialize(response)
      super "#{response.code} - #{response.body}"
    end
  end

  class << self
    attr_writer :config, :default_adapter, :http

    def default_adapter
      @default_adapter || :google
    end

    def config
      @config || {}
    end

    def http
      @http || HTTParty
    end

    # Geocodes a given query using the given adapter and options
    #
    # @param query [String] the query to geocode
    # @param adapter [String,Symbol] the adapter to use
    # @returns [Array<Geocode::Location>]
    # @raise [Geoloco::Error] if an error occurs
    # @raise [Geoloco::UnknownAdapter] if an unknown adapter is given
    # @raise [Geoloco::Forbidden] if the geocoder API returns a 403 error
    def geocode(query, adapter: default_adapter, **options)
      adapter_config = config.fetch(adapter, {}).merge(options)
      geocoder(adapter).geocode(query, **adapter_config)
    end

    private

    def geocoder(adapter)
      camelized = adapter.to_s.split('_').map(&:capitalize).join
      Geoloco::Adapters.const_get(camelized)
    rescue NameError
      raise Geoloco::UnknownAdapter
    end
  end
end
