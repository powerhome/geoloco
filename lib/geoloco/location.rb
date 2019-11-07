# frozen_string_literal: true

require 'forwardable'

module Geoloco
  Location = Struct.new(
    :full_address, :street, :number, :zipcode,
    :district, :city, :municipality, :geometry,
    :state, :state_code, :country, :country_code,
    keyword_init: true
  )

  # Location data
  #
  # @attr [String] full_address the fisical address
  # @attr [String] street number on the street
  # @attr [String] number number on the street
  # @attr [String] zipcode the zipcode of the location
  # @attr [String] district the district/county of the location
  # @attr [String] city the city of the location
  # @attr [String] state the full name of the state
  # @attr [String] country the country
  # @attr [String] country_code the 2-letter country code
  # @attr [String] municipality the municipality which the location belongs
  # @attr [Geoloco::Geometry] geometry latitude and longitude pair
  # @attr [Float] lat latitude
  # @attr [Float] lng longitude
  class Location
    extend Forwardable

    def_delegators :geometry, :lat, :lng
  end
end
