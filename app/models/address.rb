# Wrapper around results from the Geocoder search API.
#
# In particular, this wraps an address that has been returned
# from the API. It also contains class methods that allow listing
# and finding individual address records.
#
# At the moment, only US addresses are supported and all others
# are filtered out by the API.
class Address
  include ActiveSupport::Delegation

  SUPPORTED_COUNTRIES = [
    "us"
  ]

  class << self
    # Returns a list of Address objects given an address to search.
    def lookup(query)
      Geocoder.search(query, params: {
        countrycodes: SUPPORTED_COUNTRIES.join(",")
      }).map do |r|
        address = new(r)
        address if address.usable?
      end.compact
    end

    # Returns a single Address matching the given postal code.
    def for_postal_code!(code)
      results = Geocoder.search(nil, params: {
        postalcode: code,
        countrycodes: SUPPORTED_COUNTRIES.join(",")
      })

      address = if results.any?
        new(results.first)
      end

      raise ActiveRecord::RecordNotFound unless address&.usable?

      address
    end
  end

  def initialize(result)
    @result = result
  end

  def usable?
    result.postal_code
  end

  def to_param
    postal_code
  end

  def name
    "#{result.postal_code}, #{result.country}"
  end

  delegate :latitude, :longitude, :country_code, to: :result

  def postal_code
    result.postal_code.gsub(/\s+/, "")
  end

  private

  attr_reader :result
end
