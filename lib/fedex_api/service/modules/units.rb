module FedexApi
  module Service
    module Units
      units = %i[
        dimensions_unit
        weight_unit
        currency
      ]

      units.each do |unit|
        attr_writer unit

        define_method unit do
          instance_variable_get("@#{unit}") || FedexApi.send(unit)
        end
      end

      define_method :initialize do |options = {}|
        units.each do |unit|
          instance_variable_set("@#{unit}", options.delete(unit)) if options[unit]
        end

        super(options)
      end
    end
  end
end
