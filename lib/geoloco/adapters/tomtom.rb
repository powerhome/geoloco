# frozen_string_literal: true

require 'httparty'

module Geoloco
  module Adapters
    # Tomtom geocoding adapter
    module Tomtom
      GEOCODE_URL = 'https://api.tomtom.com/search/2/geocode/%s.json'

      class << self
        def geocode(address, key:)
          # wait_qps_limit_time(@last_api_call, qps_limit)
          # @last_api_call = Time.zone.now
          response = HTTParty.get(geocode_url(address), query: { key: key })
          handle_errors(response)
          map_results(response)
        end

        private

        def geocode_url(address)
          escaped_address = CGI.escape(address)
          format(GEOCODE_URL, escaped_address)
        end

        def handle_errors(response)
          raise Geoloco::Forbidden, response if response.code == 403
        end

        def map_results(response)
          response.parsed_response
                  .fetch('results', [])
                  .map(&method(:map_result))
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def map_result(result)
          address = result['address']
          geometry = Geoloco::Geometry.new(
            lat: result.dig('position', 'lat').to_f,
            lng: result.dig('position', 'lon').to_f
          )
          Geoloco::Location.new(
            geometry: geometry,
            full_address: address['freeformAddress'],
            street: address['streetName'], number: address['streetNumber'],
            city: address['municipality'], zipcode: address['postalCode'],
            district: address['countrySecondarySubdivision'],
            municipality: address['countryTertiarySubdivision'],
            state: address['countrySubdivisionName'],
            state_code: address['countrySubdivision'],
            country: address['country'], country_code: address['countryCode']
          )
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # def wait_qps_limit_time(calls_per_second)
        #   return if @last_api_call.nil?

        #   time_since_last_call = Time.zone.now - @last_api_call
        #   minimum_wait = 1.0.second / calls_per_second
        #   return if time_since_last_call > minimum_wait

        #   sleep minimum_wait - time_since_last_call
        # end
      end
    end
  end
end
