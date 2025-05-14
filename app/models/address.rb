class Address
  include ActiveSupport::Delegation

  SUPPORTED_COUNTRIES = [
    "us",
    "ca"
  ]

  class << self
    def lookup(query, countries: SUPPORTED_COUNTRIES)
      Geocoder.search(query, params: {
        countrycodes: Array(countries).join(",")
      }).map do |r|
        address = new(r)
        address if address.usable?
      end.compact
    end

    def for_postal_code!(code, country:)
      country.downcase!

      raise ActiveRecord::RecordNotFound unless SUPPORTED_COUNTRIES.include?(country)

      result = lookup(code, countries: country)

      if result.any?
        result.first
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def initialize(result)
    @result = result
  end

  def usable?

    # Some results are missing postal codes specifically
    result.postal_code && result.country_code
  end

  def to_param
    [ country_code, postal_code ]
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
