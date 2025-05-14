require "test_helper"

class WeatherTest < ActiveSupport::TestCase
  test "#current_temp returns temp + units" do
    assert_equal "55°C", mock_weather(
      "current" => { "temperature_2m" => "55" },
      "current_units" => { "temperature_2m" => "°C" }
    ).current_temp
  end

  test "#current_temp returns nil unless available" do
    assert_equal "55°C", mock_weather(
      "current" => { "temperature_2m" => "55" },
      "current_units" => { "temperature_2m" => "°C" }
    ).current_temp
  end

  test "#high_temp is reported if available" do
    assert_equal "55°C", mock_weather(
      "daily" => { "temperature_2m_max" => [ "55" ] },
      "current_units" => { "temperature_2m" => "°C" }
    ).high_temp
  end

  test "#low_temp is reported if available" do
    assert_equal "25°C", mock_weather(
      "daily" => { "temperature_2m_min" => [ "25" ] },
      "current_units" => { "temperature_2m" => "°C" }
    ).low_temp
  end

  test "#high_temp returns nil unless available" do
    assert_nil mock_weather(
      "current_units" => { "temperature_2m" => "°C" }
    ).high_temp
  end

  test "#low_temp returns nil unless available" do
    assert_nil mock_weather(
      "current_units" => { "temperature_2m" => "°C" }
    ).low_temp
  end

  def mock_weather(**json)
    Weather.new(json)
  end
end
