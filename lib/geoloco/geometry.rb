# frozen_string_literal: true

module Geoloco
  # Geometry data
  #
  # @attr [Float] lat latitude
  # @attr [Float] lng longitude
  Geometry = Struct.new(:lat, :lng, keyword_init: true)
end
