module FedexApi
  module Service
    class Pickup < Base
      include FedexApi::Service::RequestedShipment

      WSDL_FILENAME = 'PickupService_v22.wsdl'
      VERSION = {
        service_id: 'disp',
        major: 22,
        intermediate: 0,
        minor: 0
      }

      attr_accessor :pickup_location,
                    :ready_timestamp,
                    :company_close_time,
                    :package_location,
                    :remarks

      # TODO: package_location, buildingPartCode

      def create_pickup(options = {})
        options = {
          origin_detail: {
            pickup_location: pickup_location,
            ready_timestamp: ready_timestamp,
            company_close_time: company_close_time.strftime("%T%:z")
          },
          package_count: packages.count,
          total_weight: total_weight,
          carrier_code: 'FDXE',
          remarks: remarks
        }.merge(options)

        response = call(:create_pickup, options)
        FedexApi::Reply::Base.new(response.body[:create_pickup_reply])
      end


      def cancel_pickup(number:, date:, location:)
        options = {
          carrier_code: 'FDXE',
          pickup_confirmation_number: number,
          scheduled_date: date,
          location: location,
          remarks: remarks
        }
        response = call(:cancel_pickup, options)
        FedexApi::Reply::Base.new(response.body[:cancel_pickup_reply])
      end
    end
  end
end
