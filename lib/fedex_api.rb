require 'dotenv/load'
require 'savon'

require_relative 'fedex_api/reply/base'
require_relative 'fedex_api/reply/rate'
require_relative 'fedex_api/reply/ship'
require_relative 'fedex_api/reply/track'

require_relative 'fedex_api/service/modules/units'
require_relative 'fedex_api/service/modules/requested_shipment'
require_relative 'fedex_api/service/base'
require_relative 'fedex_api/service/pickup'
require_relative 'fedex_api/service/rate'
require_relative 'fedex_api/service/ship'
require_relative 'fedex_api/service/track'
require_relative 'fedex_api/service/upload_document'

module FedexApi
  class << self
    attr_accessor :user_key,
                  :user_password,
                  :client_account_number,
                  :client_meter_number,
                  :dimensions_unit,
                  :weight_unit,
                  :currency,
                  :endpoint,
                  :shipment_label_image_type,
                  :shipment_label_stock_type
  end

  def self.configure
    yield(self)
  end

  configure do |config|
    config.user_key = ENV['FEDEX_USER_KEY']
    config.user_password = ENV['FEDEX_USER_PASSWORD']
    config.client_account_number = ENV['FEDEX_ACCOUNT_NUMBER']
    config.client_meter_number = ENV['FEDEX_METER_NUMBER']

    config.dimensions_unit = 'CM'
    config.weight_unit = 'KG'
    config.currency = 'EUR'

    config.shipment_label_image_type = 'PDF'
    config.shipment_label_stock_type = 'PAPER_8.5X11_TOP_HALF_LABEL'
  end

  class Error < StandardError
  end
end
