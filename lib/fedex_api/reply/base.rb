module FedexApi
  module Reply
    class Base
      attr_reader :reply

      def initialize(reply)
        @reply = reply
      end

      def success?
        reply[:highest_severity] == 'SUCCESS'
      end
    end
  end
end
