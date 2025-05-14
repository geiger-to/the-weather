require "test_helper"

class AddressTest < ActiveSupport::TestCase
  test "postal codes do not include spaces" do
    assert_equal "M5H4H5", mock_address(postal_code: "M5H 4H5").postal_code
  end

  test "names include the postal code and country" do
    assert_equal "M5H 4H5, Canada", mock_address(postal_code: "M5H 4H5", country: "Canada").name
  end

  test "addresses without a postal code are considered unusable" do
    assert mock_address(postal_code: nil).name
  end

  def mock_address(**attrs)
    Address.new(OpenStruct.new(attrs))
  end
end
