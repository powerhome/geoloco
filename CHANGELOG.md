# Changelog

## 1.1.0

- Add API key authentication to the Google geocoding adapter
- Require Ruby >= 3.3 and target Ruby 4.0.7 for development
- Add `base64` as a runtime dependency (no longer a default gem since Ruby 3.4)
- Drop the pinned Bundler 1.x development dependency and update locked gems
- Replace Travis CI with the shared Power `ruby-gem` GitHub Actions workflow (tests on Ruby 3.3, 3.4 and 4.0, license compliance check, releases to RubyGems on `v*-geoloco` tags)
