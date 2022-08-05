module FedexApi
  module Service
    class Rate < Base
      include FedexApi::Service::RequestedShipment

      WSDL_FILENAME = 'RateService_v28.wsdl'
      VERSION = {
        service_id: 'crs',
        major: 28,
        intermediate: 0,
        minor: 0
      }

      attr_accessor :shipper, :recipient

      def get_rates(options = {})
        @currency = options.delete(:currency) if options[:currency]

        options = {
          return_transit_and_commit: true,
          requested_shipment: {
            ship_timestamp: Time.now.iso8601,
            service_type: 'INTERNATIONAL_PRIORITY',
            packaging_type: 'YOUR_PACKAGING',
            total_weight: total_weight,
            preferred_currency: currency,
            shipper: shipper,
            recipient: recipient,
            shipping_charges_payment: {
              payment_type: 'SENDER',
              payor: {
                responsible_party: {
                  account_number: FedexApi.client_account_number
                }
              }
            },
            rate_request_types: 'PREFERRED',
            package_count: packages.count,
            requested_package_line_items: requested_package_line_items
          }
        }.merge(options)

        response = call(:get_rates, options)
        FedexApi::Reply::Rate.new(response.body[:rate_reply])
      end
    end
  end
end
