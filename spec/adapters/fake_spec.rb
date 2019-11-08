# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geoloco::Adapters::Fake do
  it 'returns a location witht he given address' do
    location, = Geoloco::Adapters::Fake.geocode('123 main')

    expect(location).to be_a Geoloco::Location
    expect(location.full_address).to eql '123 main'
  end

  describe '.stubbing' do
    it 'returns the given location' do
      location = Geoloco::Location.new
      Geoloco::Adapters::Fake.stubbing(location) do
        geocoded, = Geoloco::Adapters::Fake.geocode('')

        expect(geocoded).to be location
      end
    end
  end
end
