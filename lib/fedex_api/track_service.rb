module FedexApi
  class TrackService < BaseService
    WSDL_FILENAME = 'TrackService_v16.wsdl'
    VERSION = {
      service_id: 'trck',
      major: 16,
      intermediate: 0,
      minor: 0
    }

    def track(options = {})
      options = {
        selection_details: {
          package_identifier: {
            type: 'TRACKING_NUMBER_OR_DOORTAG',
            value: '122816215025810'
          }
        },
        processing_options: 'INCLUDE_DETAILED_SCANS'
      }.merge(options)

      call(:track, options)
    end
  end
end
