module FedexApi
  module Service
    class Ship < Base
      include FedexApi::Service::RequestedShipment

      WSDL_FILENAME = 'ShipService_v28.wsdl'
      VERSION = {
        service_id: 'ship',
        major: 28,
        intermediate: 0,
        minor: 0
      }

      attr_accessor :commodities,
                    :delivery_instructions,
                    :commercial_invoice,
                    :customer_image_usages

      def initialize(*args)
        super(*args)

        @commercial_invoice = true
        @commodities = []
      end

      def process_shipment(options = {})
        @currency = options.delete(:currency) if options[:currency]

        if commercial_invoice
          special_services_requested = {
            special_service_types: 'ELECTRONIC_TRADE_DOCUMENTS',
            etd_detail: {
              requested_document_copies: 'COMMERCIAL_INVOICE'
            }
          }
          shipping_document_specification = {
            shipping_document_types: 'COMMERCIAL_INVOICE',
            commercial_invoice_detail: {
              format: {
                image_type: 'PDF',
                stock_type: 'PAPER_LETTER'
              },
              customer_image_usages: customer_image_usages
            }
          }
        end

        options = {
          requested_shipment: {
            ship_timestamp: Time.now.iso8601,
            dropoff_type: 'REGULAR_PICKUP',
            service_type: 'FEDEX_INTERNATIONAL_PRIORITY',
            packaging_type: 'YOUR_PACKAGING',
            total_weight: total_weight,
            total_insured_value: total_insured_value_hash,
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
            special_services_requested: special_services_requested,
            delivery_instructions: delivery_instructions,
            customs_clearance_detail: {
              duties_payment: {
                payment_type: 'SENDER',
                payor: {
                  responsible_party: {
                    account_number: FedexApi.client_account_number
                  }
                },
              },
              customs_value: customs_value_hash,
              commodities: commodities_array
            },
            label_specification: {
              label_format_type: 'COMMON2D',
              image_type: options[:label_image_type] || FedexApi.shipment_label_image_type,
              label_stock_type: options[:label_stock_type] || FedexApi.shipment_label_stock_type,
            },
            shipping_document_specification: shipping_document_specification,
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
