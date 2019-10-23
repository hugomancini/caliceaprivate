require 'uri'
require 'net/http'
require 'json'

class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :connectApi

  def helloWorld
    puts 'hellow hugo'
    addressName = params["addressName"]
    company = params["company"]
    street_address = params["street_address"]
    zip = params["zip"]
    city = params["city"]
    customerId = params["customer_id"]
    customerMail = params["customer_mail"]
    email = params["email"]
    line_items = JSON.parse(params["line_items"])
    puts line_items
    puts line_items.class
    puts line_items[0]["variant_id"].class
    puts line_items[0]["quantity"].class
    variant_ids = []
    line_items.each do |item|
      variant_id = item["variant_id"].to_i
      quantity = item["quantity"].to_i
      n = { "quantity" => quantity, "variant_id" => variant_id }
      variant_ids << n
    end

    create_order(variant_ids, customerId)

    render json: {order: @order}
  end

  def create_order(variant_ids, customerId)
    @order = ShopifyAPI::Order.create(line_items: variant_ids, financial_status:"authorized", customer: { id: customerId })
    @order.save
    return @order
  end

  def index
    @products = ShopifyAPI::Product.all
  end

  private

  def connectApi
    shop_url = "https://de69344ecda45841327dbd594af761e5:3623f41fc97008cf4f660757b0fe1acf@calicea.myshopify.com"
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI::Base.api_version = '2019-10'
  end

end
