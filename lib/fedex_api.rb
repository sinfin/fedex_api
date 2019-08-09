require 'savon'

require_relative 'fedex_api/modules/requested_shipment'

require_relative 'fedex_api/base_service'
require_relative 'fedex_api/rate_service'
require_relative 'fedex_api/ship_service'

module FedexApi
  class << self
    attr_accessor :weight_unit, :currency
  end

  def self.configure
    yield(self)
  end

  configure do |config|
    config.weight_unit = 'KG'
    config.currency = 'EUR'
  end
end
