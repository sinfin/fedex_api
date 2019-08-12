module FedexApi
  module Service
    class Track < Base
      WSDL_FILENAME = 'TrackService_v16.wsdl'
      VERSION = {
        service_id: 'trck',
        major: 16,
        intermediate: 0,
        minor: 0
      }

      #
      def track(*args)
        tracking_numbers = args
        track_options = args.pop if args.last.is_a?(Hash)

        raise FedexApi::Error, 'The maximum number of packages within a single track transaction is limited to 30.' if tracking_numbers.size > 30

        options = {
          selection_details: selection_details(tracking_numbers),
          processing_options: 'INCLUDE_DETAILED_SCANS'
        }
        options.merge(track_options) unless track_options.nil?

        response = call(:track, options)
        FedexApi::Reply::Track.new(response.body[:track_reply])
      end

      private
        def selection_details(tracking_numbers)
          tracking_numbers.map do |n|
            {
              package_identifier: {
                type: 'TRACKING_NUMBER_OR_DOORTAG',
                value: n
              }
            }
          end
        end
    end
  end
end
