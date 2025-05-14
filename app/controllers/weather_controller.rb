class WeatherController < ApplicationController
  caches_action :show, expires_in: 30.minutes

  def show
    @address = Address.for_postal_code!(params[:code], country: params[:country])
    @weather = Weather.for_address(@address)
  end
end
