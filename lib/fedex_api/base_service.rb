module FedexApi
  class BaseService
    def initialize
      logger = Logger.new('log/fedex_api.log')
      @client = Savon.client(wsdl: File.join( File.dirname(__FILE__), "wsdl/#{self.class::WSDL_FILENAME}"),
                             logger: logger,
                             log: true,
                             pretty_print_xml: true,
                             convert_request_keys_to: :camelcase)
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

      @client.call(method, message: base_options.merge(options))
    end
  end
end
