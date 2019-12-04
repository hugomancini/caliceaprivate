# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :connect_api

  def checkout_pro
    customer_id = params['customer_id']
    pro_price = params['pro_price'].to_i
    total_price = (params['total_price'].to_i) / 100
    customer_mail = params['customer_mail']
    cip = params['cip'].to_i
    tag = "cip- #{cip}"
    line_json = params['line_items']
    line_items = JSON.parse(line_json)
    discount_amount = (total_price - pro_price).to_f
    code_name
    variant_ids = []
    line_items.each do |item|
      variant_id = item['variant_id'].to_i
      quantity = item['quantity'].to_i
      n = { 'quantity' => quantity, 'variant_id' => variant_id }
      variant_ids << n
    end
    create_order(variant_ids, customer_id, @code_name, discount_amount, tag, cip, customer_mail)
    puts @order
    render json: { order: @order, total_price: total_price, pro_price: pro_price, dicount: discount_amount, cip: cip, status: "order_created"}
  end

  def create_order(variant_ids, customer_id, code_name, discount_amount, tag, cip, customer_mail)
    @order = ShopifyAPI::Order.new(line_items: variant_ids, tags: tag, attributes: ["CIP", cip], financial_status:"authorized", customer: { id: customer_id, email: customer_mail }, discount_codes:   [{
    'code': "PROPRICE",
    'amount': "#{discount_amount}",
    'type': 'discount_code',
    'value_type': 'fixed_amount',
    'target_selection': 'all',
    'once_per_customer': true }])
    p @order.save
    p @order.errors.full_messages
  end

  def delete_all_orders
    @orders = ShopifyAPI::Order.all
    puts "before -----------------------------------------------------"
    puts @orders.class
    puts @orders.size
    @orders.each do |o|
      puts o.class
      o.destroy
    end
    puts "after---------------------------------"
    puts @orders.size
  end
  # CREER UN CODE SUR LE BACKEND SHOPIFY DISPO TOUT LE TEMPS "PRO CODE"
  # UTILISER TOUJOURS CE CODE
  # OVERWRIDER L'AMOUNT DANS LE CREATE ORDER

  def create_pro_customer
    first_name = params["first_name"]
    last_name = params["last_name"]
    customer_mail = params["customer_mail"]
    customer_tel = params["customer_tel"]
    address1 = params["address1"]
    zip = params["zip"]
    city = params["city"]
    cip = params["cip"]
    siret = params["siret"]
    raison_sociale = params["raison_sociale"]

    puts "------------------------INSIDE CREATE PRO CUSTOMER"

    order = ShopifyAPI::Customer.new(email: customer_mail, phone: customer_tel, first_name: first_name, last_name: last_name,  addresses: [
          {
            "address1": address1,
            "city": city,
            "zip": zip,
            "last_name": last_name,
            "first_name": first_name,
            "country": "FR"
          },
          metafields: [
                 {
                   key: "tel",
                   value: customer_tel,
                   value_type: "integer",
                   namespace: "global"
                 },
                 {
                   key: "siret",
                   value: siret,
                   value_type: "integer",
                   namespace: "global"
                 },
                 {
                   key: "cip",
                   value: cip,
                   value_type: "integer",
                   namespace: "global"
                 },
                 {
                   key: "raison_sociale",
                   value: raison_sociale,
                   value_type: "string",
                   namespace: "global"
                 }
               ]
        ])
    order.save
    order.errors.messages

    render json: {answer: order, saved: order.save, error: order.errors.messages }
  end

  def code_name
    @code_name = (0...8).map { (65 + rand(26)).chr }.join
  end

  def index
    @products = ShopifyAPI::Product.all
    @orders = ShopifyAPI::Order.all
  end

  private

  def connect_api
    shop_url = 'https://de69344ecda45841327dbd594af761e5:3623f41fc97008cf4f660757b0fe1acf@calicea.myshopify.com'
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI::Base.api_version = '2019-10'
  end

end


