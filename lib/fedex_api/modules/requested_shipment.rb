module FedexApi
  module RequestedShipment
    attr_accessor :shipper, :recipient

    def initialize
      super

      @packages = []

      # defaults
      @weight_units = 'KG'
    end

    def add_package(hash)
      @packages << hash

      hash
    end

    private
      def total_weight
        {
          units: @weight_units,
          value: @packages.sum { |p| p[:weight] }
        }
      end

      def requested_package_line_items
        @packages.map.with_index(1) do |package, i|
          {
            sequence_number: i,
            group_package_count: 1,
            weight: {
              units: @weight_units,
              value: package[:weight].to_s
            }
          }
        end
      end
  end
end
