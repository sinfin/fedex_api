module FedexApi
  module Reply
    class Base
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def success?
        body[:highest_severity] == 'SUCCESS' || body[:highest_severity] == 'WARNING'
      end

      def error?
        body[:highest_severity] == 'ERROR'
      end
    end
  end
end
