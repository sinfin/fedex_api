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

module FedexApi
  class << self
    attr_accessor :dimensions_unit,
                  :weight_unit,
                  :currency,
                  :endpoint
  end

  def self.configure
    yield(self)
  end

  configure do |config|
    config.dimensions_unit = 'CM'
    config.weight_unit = 'KG'
    config.currency = 'EUR'
  end

  class Error < StandardError
  end
end
