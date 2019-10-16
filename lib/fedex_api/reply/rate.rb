module FedexApi
  module Reply
    class Rate < Base
      def shipment_rates
        body[:rate_reply_details][:rated_shipment_details]
      end

      def payor_account_shipment_rate
        find_shipment_rate('PAYOR_ACCOUNT_SHIPMENT')
      end

      def preffered_account_shipment_rate
        find_shipment_rate('PREFERRED_ACCOUNT_SHIPMENT')
      end

      def delivery_date
        body[:rate_reply_details][:delivery_timestamp].to_date
      end

      def delivery_day_of_week
        body[:rate_reply_details][:delivery_day_of_week]
      end

      private
        def find_shipment_rate(rate_type)
          return shipment_rates[:shipment_rate_detail] unless shipment_rates.is_a? Array

          shipment_rate = shipment_rates.find do |r|
            r[:shipment_rate_detail][:rate_type] == rate_type
          end

          shipment_rate[:shipment_rate_detail] if shipment_rate
        end
    end
  end
end
