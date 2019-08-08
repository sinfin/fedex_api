require_relative 'base_service'

module FedexApi
  class RateService < BaseService
    WSDL_FILENAME = 'RateService_v24.wsdl'
    VERSION = {
      service_id: 'crs',
      major: 24,
      intermediate: 0,
      minor: 0
    }

    attr_accessor :shipper, :recipient

    def initialize
      super

      @packages = []

      # defaults
      @weight_units = 'KG'
    end

    def add_package(hash)
      @packages << hash

      hash
    end

    def get_rates(options = {})
      options = {
        return_transit_and_commit: true,
        requested_shipment: {
          ship_timestamp: Time.now.iso8601,
          dropoff_type: 'REGULAR_PICKUP',
          packaging_type: 'YOUR_PACKAGING',
          total_weight: total_weight,
          shipper: shipper,
          recipient: recipient,
          shipping_charges_payment: {
            payment_type: 'SENDER',
            payor: {
              responsible_party: {
                account_number: ENV['FEDEX_ACCOUNT_NUMBER']
              }
            }
          },
          rate_request_types: 'LIST',
          package_count: @packages.count,
          requested_package_line_items: requested_package_line_items
        }
      }.merge(options)

      call(:get_rates, options)
    end

    private
      def total_weight
        {
          units: @weight_units,
          value: @packages.sum { |p| p[:weight] }
        }
      end

      def requested_package_line_items
        @packages.map.with_index(1) do |package, i|
          {
            sequence_number: i,
            group_package_count: 1,
            weight: {
              units: @weight_units,
              value: package[:weight].to_s
            }
          }
        end
      end
  end
end
