class AddressesController < ApplicationController
  def lookup
    @address = params[:address]
    @results = Address.lookup(@address)

    if @results.one?
      address = @results.first

      redirect_to weather_path(address.country_code, address.postal_code)
    else
      render :index
    end
  end
end
