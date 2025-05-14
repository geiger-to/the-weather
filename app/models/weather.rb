require "net/http"

# Wrapper around weather results from the OpenMeteo API.
class Weather
  include ActiveSupport::Delegation

  # Wraps access to the meteo client API, returning Weather objects
  # when fetching data rather than the raw JSON that is returned
  # from the API.
  class Client
    ENDPOINT = "https://api.open-meteo.com/v1/forecast"

    # Returns weather data for a given address.
    #
    # This _always_ returns a Weather object, but all data will
    # be nil unless a valid response is given.
    def for_address(address)
      params = {
        latitude: "#{address.latitude}",
        longitude: "#{address.longitude}",
        current: "temperature_2m",
        daily: "temperature_2m_min,temperature_2m_max"
      }

      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)

      json = if res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      else
        {}
      end

      Weather.new(json)
    end
  end

  class << self
    def client
      @client ||= Client.new
    end

    delegate :for_address, to: :client
  end

  def initialize(json)
    @json = json
  end

  def current_temp
    "#{temp}#{units}" if temp
  end

  def high_temp
    "#{high}#{units}" if high
  end

  def low_temp
    "#{low}#{units}" if low
  end

  private

  def units
    @json.dig("current_units", "temperature_2m")
  end

  def temp
    @json.dig("current", "temperature_2m")
  end

  def high
    @json.dig("daily", "temperature_2m_max")&.[](0)
  end

  def low
    @json.dig("daily", "temperature_2m_min")&.[](0)
  end
end
