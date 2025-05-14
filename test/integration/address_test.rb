require "test_helper"

class AddressIntegrationTest < ActionDispatch::IntegrationTest
  test "unknown addresses show an error" do
    VCR.use_cassette("address-lookup-unknown") do
      # returns nothing since only US addresses are supported
      post "/", params: { address: "1 King St West Toronto Ontario Canada" }
    end

    assert_equal 200, response.status

    assert_dom "#no-results", text: "Address not found..."
  end

  test "multiple addresses show a list of options" do
    VCR.use_cassette("address-lookup-multiple") do
      post "/", params: { address: "419 Locksley Manor" }
    end

    assert_dom ".address" do |elements|
      assert_equal 2, elements.count
    end

    assert_equal 200, response.status
  end

  test "a unique address redirects immediately to the weather page" do
    VCR.use_cassette("address-lookup-one") do
      post "/", params: { address: "549 Cardiff Dr Austin Texas" }
    end

    assert_equal 302, response.status
    assert_redirected_to "/78745"
  end
end
