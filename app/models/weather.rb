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
        hourly: "temperature_2m"
      }

      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)

      if res.is_a?(Net::HTTPSuccess)
        json = JSON.parse(res.body)
      else
        raise "invalid response"
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

  def temp
    "#{temperature}#{units}"
  end

  def temperature
    @json.dig("current", "temperature_2m")
  end

  def units
    @json.dig("current_units", "temperature_2m")
  end
end
