module FedexApi
  module Service
    module RequestedShipment
      attr_accessor :shipper, :recipient, :packages

      def initialize
        super

        @packages = []
      end

      private
        def total_weight
          {
            units: FedexApi.weight_unit,
            value: packages.sum { |p| p[:weight] }
          }
        end

        def requested_package_line_items
          packages.map.with_index(1) do |package, i|
            p = {
              sequence_number: i,
              group_package_count: 1,
              weight: {
                units: FedexApi.weight_unit,
                value: package[:weight].to_s
              }
            }

            p[:dimensions] = {
              length: package[:length],
              width: package[:width],
              height: package[:height],
              units: FedexApi.dimensions_unit
            } if package[:length] || package[:width] || package[:height]

            p
          end
        end
    end
  end
end
