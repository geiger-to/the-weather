require "net/http"

class Weather
  include ActiveSupport::Delegation

  class Client
    ENDPOINT = "https://api.open-meteo.com/v1/forecast"

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
