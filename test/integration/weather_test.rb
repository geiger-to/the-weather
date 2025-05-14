require "test_helper"

class WeatherIntegrationTest < ActionDispatch::IntegrationTest
  test "unknown countries return a 404" do
    get "/invalid/00000"

    assert_equal 404, response.status
  end

  test "US zip codes are supported country code" do
    VCR.use_cassette("weather-us-63304") do
      get "/63304"

      assert_equal 200, response.status
    end
  end

  test "responses are cached by country/zip code" do
    VCR.use_cassette("weather-us-63305") do
      get "/63305"
    end

    # If caches aren't present this will cause webmock to raise an exception
    get "/63305"

    VCR.use_cassette("weather-us-63303") do
      get "/63303"
    end

    assert_equal 200, response.status
  end

  test "responses are cached for 30 minutes" do
    freeze_time

    VCR.use_cassette("weather-us-63301-1") do
      get "/63301"

      assert_dom "#cache-status", text: "Cached: no"
    end

    travel 29.minutes + 59.seconds

    get "/63301"

    assert_dom "#cache-status", text: "Cached: yes"

    assert_equal 200, response.status

    travel 1.second

    VCR.use_cassette("weather-us-63301-2") do
      get "/63301"
    end
  end
end
