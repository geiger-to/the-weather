require "test_helper"

class WeatherTest < ActiveSupport::TestCase
  test "temp includes the current temp and units" do
    assert_equal "55°C", mock_weather(
      "current" => { "temperature_2m" => "55" },
      "current_units" => { "temperature_2m" => "°C" }
    ).temp
  end

  def mock_weather(**json)
    Weather.new(json)
  end
end
