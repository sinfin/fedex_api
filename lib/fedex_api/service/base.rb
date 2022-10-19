module FedexApi
  module Service
    class Base
      def initialize(options = {})
        wsdl_path = File.join(File.dirname(__FILE__), "wsdl/#{self.class::WSDL_FILENAME}")
        @client = Savon.client(wsdl: wsdl_path,
                               convert_request_keys_to: :camelcase,
                               endpoint: FedexApi.endpoint)
      end

      def operations
        @client.operations
      end

      def call(method, options)
        base_options = {
          web_authentication_detail: {
            user_credential: {
              key: FedexApi.user_key,
              password: FedexApi.user_password
            }
          },
          client_detail: {
            account_number: FedexApi.client_account_number,
            meter_number: FedexApi.client_meter_number
          },
          version: self.class::VERSION
        }

        message = hash_deep_compact(base_options.merge(options))
        @client.call(method, message: message)
      end

      private
        def hash_deep_compact(obj)
          case obj
          when Hash
            obj.keys.each do |key|
              hash_deep_compact(obj[key])
            end

            obj.delete_if { |k, v| v.nil? || v == {} }
          when Array
            obj.map { |i| hash_deep_compact(i) }.compact
          else
            obj
          end
        end
    end
  end
end
