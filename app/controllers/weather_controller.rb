class WeatherController < ApplicationController
  before_action :set_cache_status

  caches_action :show, expires_in: 30.minutes, layout: false

  def show
    @cached = false    # Only set when the page is caching
    @address = Address.for_postal_code!(params[:code])
    @weather = Weather.for_address(@address)
  end

  private

  def set_cache_status
    @cached_page = true
    @cached = true
  end
end
