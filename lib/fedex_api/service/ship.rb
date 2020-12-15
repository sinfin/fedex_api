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

      attr_accessor :commodities,
                    :delivery_instructions,
                    :customer_image_usages

      def initialize(*args)
        super(*args)

        @commodities = []
      end

      def process_shipment(options = {})
        @currency = options.delete(:currency) if options[:currency]

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
            special_services_requested: {
              special_service_types: 'ELECTRONIC_TRADE_DOCUMENTS',
              etd_detail: {
                requested_document_copies: 'COMMERCIAL_INVOICE'
              }
            },
            delivery_instructions: delivery_instructions,
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
              commodities: commodities_array
            },
            label_specification: {
              label_format_type: 'COMMON2D',
              image_type: 'PDF',
              label_stock_type: 'PAPER_8.5X11_TOP_HALF_LABEL'
            },
            shipping_document_specification: {
              shipping_document_types: 'COMMERCIAL_INVOICE',
              commercial_invoice_detail: {
                format: {
                  image_type: 'PDF',
                  stock_type: 'PAPER_LETTER'
                },
                customer_image_usages: customer_image_usages
              }
            },
            package_count: packages.count,
            requested_package_line_items: requested_package_line_items
          }
        }.merge(options)

        response = call(:process_shipment, options)
        FedexApi::Reply::Ship.new(response.body[:process_shipment_reply])
      end

      private
        def currency
          @currency || FedexApi.currency
        end

        def commodities_array
          commodities.map do |hash|
            %i[
              description
              country_of_manufacture
              unit_price
              customs_value
              weight
            ].each do |required_key|
              raise "commodities: #{required_key} is required!" if !hash.key?(required_key)
            end

            commodity = hash.dup
            %i[unit_price customs_value].each do |key|
              commodity[key] = {
                currency: currency,
                amount: commodity[key]
              }
            end

            {
              number_of_pieces: 1,
              description: commodity.delete(:description),
              country_of_manufacture: commodity.delete(:country_of_manufacture),
              harmonized_code: commodity.delete(:harmonized_code),
              weight: {
                units: FedexApi.weight_unit,
                value: commodity.delete(:weight)
              },
              quantity: 1,
              quantity_units: 'UNIT'
            }.merge(commodity)
          end
        end

        def total_insured_value_hash
          {
            currency: currency,
            amount: commodities.map {|c| c[:quantity] * c[:unit_price] }.sum
          }
        end

        def customs_value_hash
          {
            currency: currency,
            amount: commodities.map {|c| c[:customs_value] }.sum
          }
        end
    end
  end
end
