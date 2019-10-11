module FedexApi
  module Reply
    class Base
      attr_reader :body

      def initialize(body)
        @body = body
      end

      def success?
        body[:highest_severity] == 'SUCCESS'
      end

      def error?
        body[:highest_severity] == 'ERROR'
      end
    end
  end
end
