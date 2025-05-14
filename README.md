# The Weather

This is a Rails 8 application that adheres to the specifications outlined in the
corresponding [specification.pdf](specification.pdf). In particular, this
application exposes a simple web-based UI and HTTP API that allows anyone to
look up current and forecasted weather data for a given address.

## Usage

Try the demo:

> https://the-weather-99dg.onrender.com

Or `git clone` the repo to run locally:

```
git clone https://github.com/geiger-to/the-weather.git
cd the-weather
bundle
bin/setup
```

After setup run the server or tests with:

```
bin/rails server  # run the server
bin/rails test    # run the test suite
```

## How it works

There are two endpoints available:

- `GET|POST /` for searching address data
- `GET /:zip_code` for viewing weather data for a given zip code

These endpoints rely on two external APIs:

 1. The Nominatim API (from OpenStreetMap) is used for address lookups and
translating zip codes to latitude/longitude data.

 2. The OpenMeteo API is used for gathering weather data for a given
latitude/longitude.

## What's missing

 - There is a bug with forecasted high/low data. Another API dependency must be
   introduced to translate a zip code (or lat/long) to a timezone. The Meteo
   API uses GMT by default and as such high/low data does not reflect the proper
   start and end-times for any given zip code in the USA.

 - There is no UI styling. Given more time and input I would flesh this out more
   depending on what's needed. For now, I've included a bare-bones HTML-only UI.

 - There is no CI/CD/linting pipeline, something I'd add for any real production
 service.

### Caching

Although some caching is in place, it is somewhat underspecified.

Depending on actual production requirements, I would look to introduce either
full-page caching, allowing the rails app to be skipped when showing cached
weather data. Or I would use a more suitable backend for storing cached data,
a proper database, Redis, or Memcached would fare much better with real traffic.
Right now, SQLite is used (by way of solid_cache) simply for demonstrative/testing
purposes.

Regardless, there are still scalability concerns with this implementation. There
are _a lot_ of addresses one can search for and in likelihood there will be a
cache miss. Additional protection should be put in place depending on where
this application is deployed.

At the very least, I'd recommend some sort of friction before searching for
addresses. Requiring a captcha, valid email or login, or adding some other sort
of throttling/ bot protection would suffice. If this application is deployed on
some lower-traffic internal network, what exists likely fine.
