require "test_helper"

class WeatherIntegrationTest < ActionDispatch::IntegrationTest
  test "unknown countries return a 404" do
    get "/invalid/00000"

    assert_equal 404, response.status
  end

  test "CA is a supported country code" do
    VCR.use_cassette("weather-ca-M5H64B") do
      get "/ca/M6P4H5"

      assert_equal 200, response.status
    end
  end

  test "US is a supported country code" do
    VCR.use_cassette("weather-us-63304") do
      get "/us/63304"

      assert_equal 200, response.status
    end
  end

  test "responses are cached by country/zip code" do
    VCR.use_cassette("weather-us-63305") do
      get "/us/63305"
    end

    # If caches aren't present this will cause webmock to raise an exception
    get "/us/63305"

    VCR.use_cassette("weather-us-63303") do
      get "/us/63303"
    end

    assert_equal 200, response.status
  end

  test "responses are cached for 30 minutes" do
    freeze_time

    VCR.use_cassette("weather-us-63301-1") do
      get "/us/63301"
    end

    travel 29.minutes + 59.seconds

    get "/us/63301"

    assert_equal 200, response.status

    travel 1.second

    VCR.use_cassette("weather-us-63301-2") do
      get "/us/63301"
    end
  end
end
