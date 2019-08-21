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

      def process_shipment(options = {})
        options = {
          requested_shipment: {
            ship_timestamp: Time.now.iso8601,
            dropoff_type: 'REGULAR_PICKUP',
            service_type: 'INTERNATIONAL_PRIORITY',
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
              customs_value: {
                currency: FedexApi.currency,
                amount: 10
              },
              commodities: {
                number_of_pieces: 1,
                description: 'test',
                country_of_manufacture: 'CZ',
                weight: total_weight,
                quantity: 1,
                quantity_units: 'UNIT',
                unit_price: {
                  currency: FedexApi.currency,
                  amount: 10
                },
                customs_value: {
                  currency: FedexApi.currency,
                  amount: 10
                }
              }
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
    end
  end
end
