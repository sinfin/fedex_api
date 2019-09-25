module FedexApi
  module Service
    class Base
      def initialize(options = {})
        wsdl_path = File.join(File.dirname(__FILE__), "wsdl/#{self.class::WSDL_FILENAME}")
        @client = Savon.client(wsdl: wsdl_path,
                               convert_request_keys_to: :camelcase,
                               endpoint: options[:endpoint])
      end

      def operations
        @client.operations
      end

      def call(method, options)
        base_options = {
          web_authentication_detail: {
            user_credential: {
              key: ENV['FEDEX_USER_KEY'],
              password: ENV['FEDEX_USER_PASSWORD']
            }
          },
          client_detail: {
            account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
            meter_number: ENV['FEDEX_METER_NUMBER']
          },
          transaction_detail: {
            customer_transaction_id: "FedexApiTest_#{Time.now.to_i}"
          },
          version: self.class::VERSION
        }

        message = hash_deep_compact(base_options.merge(options))
        @client.call(method, message: message)
      end

      private
        def hash_deep_compact(obj)
          return obj unless obj.is_a?(Hash)

          obj.keys.each do |key|
            hash_deep_compact(obj[key])
          end

          obj.delete_if { |k, v| v.nil? || v == {} }
        end
    end
  end
end
