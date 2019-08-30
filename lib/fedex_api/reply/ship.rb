module FedexApi
  module Reply
    class Ship < Base
      def label_image
        body[:completed_shipment_detail][:completed_package_details][:label][:parts][:image]
      end

      def label_image_type
        body[:completed_shipment_detail][:completed_package_details][:image_type]
      end

      def tracking_number
        body[:completed_shipment_detail][:master_tracking_id][:tracking_number]
      end
    end
  end
end
