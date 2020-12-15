module FedexApi
  module Service
    class UploadDocument < Base
      WSDL_FILENAME = 'UploadDocumentService_v17.wsdl'
      VERSION = {
        service_id: 'cdus',
        major: 17,
        intermediate: 0,
        minor: 0
      }

      # max image size 700x50 - encoded as Base64 string
      def upload_image(id, image)
        options = {
          images: {
            id: id,
            image: image
          }
        }

        response = call(:upload_images, options)
      end
    end
  end
end
