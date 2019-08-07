require_relative 'base_service'

module FedexApi
  class RateService < BaseService
    WSDL_FILENAME = 'RateService_v24.wsdl'

    def initialize
      super(WSDL_FILENAME)
    end

    def version
      {
        service_id: 'crs',
        major: 24,
        intermediate: 0,
        minor: 0
      }
    end

    def get_rates
      options = {
        return_transit_and_commit: true,
        requested_shipment: {
          ship_timestamp: Time.now.iso8601,
          dropoff_type: 'REGULAR_PICKUP',
          packaging_type: 'YOUR_PACKAGING',
          total_weight: {
            units: 'LB',
            value: '20.0'
          },
          shipper: {
            contact: {
              company_name: 'test',
              phone_number: '12345678'
            },
            address: {
                 street_lines: [ 'address 1', 'address 2' ],
                 city: 'Austin',
                 state_or_province_code: 'TX',
                 postal_code: '73301',
                 country_code: 'US'
            }
          },
          recipient: {
            contact: {
              company_name: 'test2',
              phone_number: '98765432'
            },
            address: {
                 street_lines: 'address',
                 city: 'Collierville',
                 state_or_province_code: 'TN',
                 postal_code: '38017',
                 country_code: 'US'
            }
          },
          shipping_charges_payment: {
            payment_type: 'SENDER'
          },
          rate_request_types: 'LIST',
          package_count: 1,
          requested_package_line_items: {
            sequence_number: 1,
            group_number: 1,
            group_package_count: 1,
            weight: {
              units: 'LB',
              value: '20.0'
            },
            dimensions: {
              length: 12,
              width: 12,
              height: 12,
              units: 'IN'
            },
            content_records: {
              part_number: 13234,
              item_number: 'xyz123',
              received_quantity: 12,
              description: 'test'
            }
          }
        }
      }

      call(:get_rates, options)
    end
  end
end
