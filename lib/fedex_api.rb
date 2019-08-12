require 'savon'


require_relative 'fedex_api/reply/base'

require_relative 'fedex_api/service/modules/requested_shipment'
require_relative 'fedex_api/service/base'
require_relative 'fedex_api/service/rate'
require_relative 'fedex_api/service/ship'
require_relative 'fedex_api/service/track'

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

  class Error < StandardError
  end
end
