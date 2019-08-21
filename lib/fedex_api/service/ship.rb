module FedexApi
  module Service
    class Ship < Base
      include FedexApi::Service::RequestedShipment

      WSDL_FILENAME = 'ShipService_v25.wsdl'
      VERSION = {
        service_id: 'ship',
        major: 25,
        intermediate: 0,
        minor: 0
      }

      attr_accessor :total_insured_value,
                    :customs_value,
                    :commodities

      def value=(num)
        @total_insured_value = num
        @customs_value = num
      end

      def process_shipment(options = {})
        options = {
          requested_shipment: {
            ship_timestamp: Time.now.iso8601,
            dropoff_type: 'REGULAR_PICKUP',
            service_type: 'INTERNATIONAL_PRIORITY',
            packaging_type: 'YOUR_PACKAGING',
            total_weight: total_weight,
            total_insured_value: total_insured_value_hash,
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
            delivery_instructions: 'My instructions for delivery',
            customs_clearance_detail: {
              duties_payment: {
                payment_type: 'SENDER',
                payor: {
                  responsible_party: {
                    account_number: ENV['FEDEX_ACCOUNT_NUMBER']
                  }
                }
              },
              customs_value: customs_value_hash,
              commodities: commodities_hash
            },
            label_specification: {
              label_format_type: 'COMMON2D',
              image_type: 'PDF',
              label_stock_type: 'PAPER_8.5X11_TOP_HALF_LABEL'
            },
            shipping_document_specification: {
              shipping_document_types: 'LABEL'
            },
            package_count: packages.count,
            requested_package_line_items: requested_package_line_items
          }
        }.merge(options)

        response = call(:process_shipment, options)
        FedexApi::Reply::Ship.new(response.body[:process_shipment_reply])
      end

      private
        def commodities_hash
          hash = commodities.dup

          %i[unit_price customs_value].each do |key|
            hash[key] = {
              currency: FedexApi.currency,
              amount: hash[key]
            }
          end

          {
            number_of_pieces: 1,
            description: hash.delete(:description),
            country_of_manufacture: hash.delete(:country_of_manufacture),
            weight: total_weight,
            quantity: 1,
            quantity_units: 'UNIT'
          }.merge(hash)
        end

        def total_insured_value_hash
          {
            currency: FedexApi.currency,
            amount: total_insured_value
          }
        end

        def customs_value_hash
          {
            currency: FedexApi.currency,
            amount: customs_value
          }
        end
    end
  end
end
