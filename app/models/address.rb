class Address
  include ActiveSupport::Delegation

  SUPPORTED_COUNTRIES = [
    "us"
  ]

  class << self
    def lookup(query)
      Geocoder.search(query, params: {
        countrycodes: SUPPORTED_COUNTRIES.join(",")
      }).map do |r|
        address = new(r)
        address if address.usable?
      end.compact
    end

    def for_postal_code!(code)
      result = lookup(code)

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
