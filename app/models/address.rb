class Address
  include ActiveSupport::Delegation

  class << self
    def lookup(query)
      results = Geocoder.search(query)
      results.map do |r|
        new(r)
      end
    end

    def for_postal_code!(code, country:)
      result = Geocoder.search(code, params: {
        countrycodes: country
      })

      if result.any?
        new(result.first)
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def initialize(result)
    @result = result
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
