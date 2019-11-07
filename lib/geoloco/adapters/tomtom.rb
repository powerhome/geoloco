# frozen_string_literal: true

require 'httparty'

module Geoloco
  module Adapters
    # Tomtom geocoding adapter
    module Tomtom
      GEOCODE_URL = 'https://api.tomtom.com/search/2/geocode/%s.json'

      class << self
        def geocode(address, key:, qps_limit: 5)
          wait_qps_limit_time(qps_limit) unless qps_limit&.zero?
          response = HTTParty.get(geocode_url(address), query: { key: key })
          handle_errors(response)
          map_results(response.parsed_response)
        end

        private

        def geocode_url(address)
          escaped_address = CGI.escape(address)
          format(GEOCODE_URL, escaped_address)
        end

        def handle_errors(response)
          raise Geoloco::Forbidden, response if response.code == 403
        end

        def map_results(parsed)
          parsed.fetch('results', [])
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

        def wait_qps_limit_time(qps_limit)
          time_since_last_call = @last_api_call ? Time.now - @last_api_call : 2
          wait_time = 1.0 / qps_limit.to_f - time_since_last_call
          sleep wait_time if wait_time.positive?
          @last_api_call = Time.now
        end
      end
    end
  end
end
