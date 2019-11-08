# frozen_string_literal: true

require 'base64'
require 'openssl'

module Geoloco
  module Adapters
    # Google geocoding adapter
    module Google
      API_HOST = 'https://maps.googleapis.com'
      GEOCODE_PATH = '/maps/api/geocode/json'

      class << self
        def geocode(address, client_id:, key:)
          response = Geoloco.http.get(geocode_url(address, client_id, key))
          handle_errors(response, response.parsed_response)
          map_results(response.parsed_response)
        end

        private

        def handle_errors(response, parsed)
          raise Geoloco::Forbidden, response if response.code == 403

          status = parsed&.dig('status')
          return if status.eql?('OK')

          message = parsed&.dig('error_message')

          raise Geoloco::Error, [status, message].compact.join(' - ')
        end

        def map_results(parsed)
          parsed.fetch('results', [])
                .map(&method(:map_result))
        end

        # rubocop:disable Metrics/MethodLength, Metrics/LineLength, Metrics/AbcSize
        def map_result(result)
          loc = result.dig('geometry', 'location') || {}
          geometry = Geoloco::Geometry.new(lat: loc['lat'], lng: loc['lng'])

          Geoloco::Location.new(
            geometry: geometry,
            full_address: result.dig('formatted_address'),
            street: get_component(result, 'route'),
            city: get_component(result, 'locality'),
            district: get_component(result, 'administrative_area_level_2'),
            municipality: get_component(result, 'administrative_area_level_3'),
            number: get_component(result, 'street_number'),
            state: get_component(result, 'administrative_area_level_1'),
            state_code: get_component(result, 'administrative_area_level_1', 'short_name'),
            zipcode: get_component(result, 'postal_code'),
            country: get_component(result, 'country'),
            country_code: get_component(result, 'country', 'short_name')
          )
        end
        # rubocop:enable Metrics/MethodLength, Metrics/LineLength, Metrics/AbcSize

        def get_component(result, type, data = 'long_name')
          result.fetch('address_components', [])
                .find { |component| component['types'].include?(type) }
                &.dig(data)
        end

        def geocode_url(address, client_id, key)
          query = URI.encode_www_form(client: client_id, address: address)
          signed_url(GEOCODE_PATH, query, key)
        end

        def signed_url(path, query, key)
          decoded_key = Base64.decode64(key.tr('-_', '+/'))
          path_query = "#{path}?#{query}"
          signature = OpenSSL::HMAC.digest('sha1', decoded_key, path_query)
          base64_signature = Base64.strict_encode64(signature).tr('+/', '-_')
          "#{API_HOST}#{path_query}&signature=#{base64_signature}"
        end
      end
    end
  end
end
