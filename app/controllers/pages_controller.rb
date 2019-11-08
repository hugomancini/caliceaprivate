# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :connect_api

  def checkout_pro
    customer_id = params['customer_id']
    total_pro = params['total_pro'].to_i
    total_price = (params['total_price'].to_i) / 100
    line_json = params['line_items']
    line_items = JSON.parse(line_json)
    discount_amount = (total_price - total_pro).to_f
    code_name
    variant_ids = []
    line_items.each do |item|
      variant_id = item['variant_id'].to_i
      quantity = item['quantity'].to_i
      n = { 'quantity' => quantity, 'variant_id' => variant_id }
      variant_ids << n
    end
    puts @order

    create_order(variant_ids, customer_id, @code_name, discount_amount)

    render json: { order: @order }
  end

  def create_order(variant_ids, customer_id, code_name, discount_amount)
    @order = ShopifyAPI::Order.new(line_items: variant_ids, financial_status:"authorized", customer: { id: customer_id }, discount_codes:   [{
    'code': "PROPRICE",
    'amount': "#{discount_amount}",
    'type': 'discount_code',
    'value_type': 'fixed_amount',
    'target_selection': 'all',
    'once_per_customer': true }])
    p @order
    p @order.save
  end

  def delete_all_orders
    @orders = ShopifyAPI::Order
    puts "before -----------------------------------------------------"
    puts order_size = @orders.size

    render json: {size: order_size}
  end
  # CREER UN CODE SUR LE BACKEND SHOPIFY DISPO TOUT LE TEMPS "PRO CODE"
  # UTILISER TOUJOURS CE CODE
  # OVERWRIDER L'AMOUNT DANS LE CREATE ORDER

  def code_name
    @code_name = (0...8).map { (65 + rand(26)).chr }.join
  end

  def index
    @products = ShopifyAPI::Product.all
  end

  private

  def connect_api
    shop_url = 'https://de69344ecda45841327dbd594af761e5:3623f41fc97008cf4f660757b0fe1acf@calicea.myshopify.com'
    ShopifyAPI::Base.site = shop_url
    ShopifyAPI::Base.api_version = '2019-10'
  end

end


