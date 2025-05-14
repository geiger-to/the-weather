require "geocoder/lookups/nominatim"

Geocoder::Lookup.street_services << :nominatim_with_postal_code

Rails.application.config.to_prepare do
  module Geocoder::Lookup
    class NominatimWithPostalCode < Geocoder::Lookup::Nominatim
      private

      def query_url_params(query)
        params = super

        if postal_code = query.options&.dig(:params, :postalcode)
          params.delete(:q)
          params[:postalcode] = postal_code
        end

        params
      end
    end
  end

  module Geocoder::Result
    class NominatimWithPostalCode < Geocoder::Result::Nominatim
    end
  end
end

Geocoder.configure(
  cache: Geocoder::CacheStore::Generic.new(Rails.cache, {}),
  lookup: :nominatim_with_postal_code
)
