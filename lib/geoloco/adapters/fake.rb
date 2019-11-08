# frozen_string_literal: true

module Geoloco
  module Adapters
    # Fake geocoding adapter
    module Fake
      class << self
        DEFAULT_GEO = Geoloco::Geometry.new(lat: -19.9191248, lng: -43.9386291)

        def geocode(address, **_options)
          location = @stub || Geoloco::Location.new(
            geometry: DEFAULT_GEO,
            full_address: address
          )
          [location]
        end

        def stubbing(location)
          @stub = location
          yield
          @stub = nil
        end
      end
    end
  end
end
