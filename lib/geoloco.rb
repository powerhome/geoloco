# frozen_string_literal: true

require 'geoloco/version'
require 'geoloco/location'
require 'geoloco/geometry'
require 'geoloco/adapters/tomtom'

module Geoloco
  # Top level Geoloco's error class
  class Error < StandardError; end

  # Forbidden error class. Raised by adapters when a forbidden
  # error is received from the providers
  class Forbidden < Geoloco::Error
    def initialize(response)
      super "#{response.code} - #{response.body}"
    end
  end
end
