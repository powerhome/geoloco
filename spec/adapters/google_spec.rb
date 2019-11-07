# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geoloco::Adapters::Google do
  let(:success_json) do
    File.read(File.expand_path('../support/google-payload.json', __dir__))
  end
  let(:parsed_success) { JSON.parse(success_json) }
  let(:success_response) do
    double(code: 200, success?: true, parsed_response: parsed_success)
  end

  describe '.geocode' do
    it 'geocodes an address' do
      expect(::HTTParty).to(
        receive(:get)
          .with(
            'https://maps.googleapis.com/maps/api/geocode/json?' \
            'client=123&address=2012+Main+St' \
            '&signature=A2W_ZT5buhOXo7P-xzb55t1wdZ8='
          )
          .and_return(success_response)
      )

      loc, = Geoloco::Adapters::Google.geocode('2012 Main St', key: '123-key',
                                                               client_id: '123')
      expect(loc).to be_instance_of Geoloco::Location
      expect(loc.full_address).to eql '2012 Main St, Narvon, PA 17555, USA'
    end

    it 'maps all location data' do
      expect(::HTTParty).to receive(:get) { success_response }

      loc, = Geoloco::Adapters::Google.geocode('2012 Main St', key: '123-key',
                                                               client_id: '123')

      expect(loc.full_address).to eql '2012 Main St, Narvon, PA 17555, USA'
      expect(loc.street).to eql 'Main Street'
      expect(loc.number).to eql '2012'
      expect(loc.city).to eql 'Narvon'
      expect(loc.zipcode).to eql '17555'
      expect(loc.district).to eql 'Lancaster County'
      expect(loc.municipality).to eql 'Caernarvon Township'
      expect(loc.state).to eql 'Pennsylvania'
      expect(loc.state_code).to eql 'PA'
      expect(loc.country).to eql 'United States'
      expect(loc.country_code).to eql 'US'
    end

    it 'raises Geoloco::Forbidden when a 403 is received' do
      expect(::HTTParty).to receive(:get) do
        double(code: 403, body: 'Evil body', parsed_response: {})
      end

      expect do
        Geoloco::Adapters::Google.geocode('address', key: 'any', client_id: '1')
      end.to raise_error(Geoloco::Forbidden, '403 - Evil body')
    end

    it 'raises Geoloco::Error when a not OK response is received' do
      parsed_error = {
        'status' => 'OVER_DAILY_LIMIT',
        'error_message' => 'gimme moar money'
      }
      expect(::HTTParty).to receive(:get) do
        double(code: 200, parsed_response: parsed_error)
      end

      expect do
        Geoloco::Adapters::Google.geocode('address', key: 'any', client_id: '1')
      end.to raise_error(Geoloco::Error, 'OVER_DAILY_LIMIT - gimme moar money')
    end
  end
end
