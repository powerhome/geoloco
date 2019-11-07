# frozen_string_literal: true

RSpec.describe Geoloco do
  it 'has a version number' do
    expect(Geoloco::VERSION).not_to be nil
  end

  describe '.geocode(address, options)' do
    it 'geocodes using the given adapter' do
      expect(Geoloco::Adapters::Tomtom).to(
        receive(:geocode)
          .with('123 main st', key: '123')
          .and_return(['location'])
      )

      locations = Geoloco.geocode('123 main st', adapter: :tomtom, key: '123')

      expect(locations).to eql ['location']
    end

    it 'raises an Geoloco::UnknownAdapter error if an unknown adatper is given' do
      expect do
        Geoloco.geocode('lol', adapter: :unknown)
      end.to raise_error Geoloco::UnknownAdapter
    end

    it 'uses the global config of the given adapter' do
      Geoloco.config = {
        tomtom: { key: 'lol-key' }
      }

      expect(Geoloco::Adapters::Tomtom).to(
        receive(:geocode)
          .with('lol', key: 'lol-key')
      )

      Geoloco.geocode('lol', adapter: :tomtom)
    end

    it 'allows overriding the global config of the given adapter' do
      Geoloco.config = {
        tomtom: { key: 'lol-key' }
      }

      expect(Geoloco::Adapters::Tomtom).to(
        receive(:geocode)
          .with('lol', key: 'sad-key')
      )

      Geoloco.geocode('lol', adapter: :tomtom, key: 'sad-key')
    end

    it 'uses the default adapter when none is given' do
      Geoloco.config = { tomtom: { key: 'lol-key' } }
      Geoloco.default_adapter = :tomtom

      expect(Geoloco::Adapters::Tomtom).to(
        receive(:geocode)
          .with('lol', key: 'lol-key')
      )

      Geoloco.geocode('lol')
    end
  end
end
