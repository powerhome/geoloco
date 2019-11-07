# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geoloco::Adapters::Tomtom do
  let(:success_json) do
    File.read(File.expand_path('../support/tomtom-payload.json', __dir__))
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
            'https://api.tomtom.com/search/2/geocode/3140+dan+ave.json',
            query: { key: '123-key' }
          )
          .and_return(success_response)
      )

      loc, = Geoloco::Adapters::Tomtom.geocode('3140 dan ave', key: '123-key')
      expect(loc).to be_instance_of Geoloco::Location
      expect(loc.full_address).to eql '3140 Dan Ave, Collegeville, PA 19415'
    end

    it 'maps all location data' do
      expect(::HTTParty).to receive(:get) { success_response }

      loc, = Geoloco::Adapters::Tomtom.geocode('3140 dan ave', key: '123-key')

      expect(loc.full_address).to eql '3140 Dan Ave, Collegeville, PA 19415'
      expect(loc.street).to eql 'Dan Ave'
      expect(loc.number).to eql '3140'
      expect(loc.city).to eql 'Collegeville, Evansburg'
      expect(loc.zipcode).to eql '19415'
      expect(loc.district).to eql 'Montgomery'
      expect(loc.municipality).to eql 'Skippack'
      expect(loc.state).to eql 'Pennsylvania'
      expect(loc.state_code).to eql 'PA'
      expect(loc.country).to eql 'United States'
      expect(loc.country_code).to eql 'US'
    end

    it 'raises Geoloco::Forbidden when a 403 is received' do
      expect(::HTTParty).to receive(:get) do
        double(code: 403, body: 'Evil body')
      end

      expect do
        Geoloco::Adapters::Tomtom.geocode('address', key: 'any')
      end.to raise_error(Geoloco::Forbidden, '403 - Evil body')
    end

    describe 'Query Per Second limit (qps_limit)' do
      before do
        allow(::HTTParty).to receive(:get) { success_response }
      end

      it 'sleeps until it is safe to make another api call respecting the limit' do
        Timecop.freeze do
          Geoloco::Adapters::Tomtom.geocode('adress', key: 'key', qps_limit: 5)

          expect(Geoloco::Adapters::Tomtom).to receive(:sleep).with(0.2)
          Geoloco::Adapters::Tomtom.geocode('adress', key: 'key', qps_limit: 5)

          expect(Geoloco::Adapters::Tomtom).to receive(:sleep).with(0.5)
          Geoloco::Adapters::Tomtom.geocode('adress', key: 'key', qps_limit: 2)
        end
      end
    end
  end
end
