require 'uri'
require 'net/http'
require 'json'

class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def helloWorld
    puts 'hellow hugo'
    addressName = params["addressName"]
    company = params["company"]
    street_address = params["street_address"]
    zip = params["zip"]
    city = params["city"]
    country = params["country"]
    customerId = params["customer_id"]
    customerName = params["customer_name"]
    puts customerName
    data = "API CALL OK !"
    render json: {answer: data}
  end



end
