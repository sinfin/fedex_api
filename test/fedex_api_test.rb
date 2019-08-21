require 'minitest/autorun'
require 'dotenv/load'
require 'fedex_api'

class FedexApiTest < Minitest::Test
  def setup
    @shipper = {
      account_number: ENV['FEDEX_ACCOUNT_NUMBER'],
      contact: {
        company_name: 'test',
        phone_number: '12345678'
      },
      address: {
           street_lines: [ 'address 1', 'address 2' ],
           city: 'Prague 1',
           postal_code: '10100',
           country_code: 'CZ'
      }
    }
    @recipient = {
      contact: {
        company_name: 'test2',
        phone_number: '87654321'
      },
      address: {
           street_lines: 'address',
           city: 'Brussels',
           postal_code: '1000',
           country_code: 'BE'
      }
    }
  end

  def test_configuration
    assert FedexApi.currency == 'EUR'
    FedexApi.currency = 'USD'
    assert FedexApi.currency == 'USD'
  end

  def test_rate_service
    service = FedexApi::Service::Rate.new
    service.shipper = @shipper
    service.recipient = @recipient
    service.packages << { weight: 1, length: 10, width: 10, height: 10 }
    reply = service.get_rates

    assert reply.success?
  end

  def test_ship_service
    service = FedexApi::Service::Ship.new
    service.shipper = @shipper
    service.recipient = @recipient
    service.packages << { weight: 1, length: 10, width: 10, height: 10 }
    reply = service.process_shipment

    assert reply.success?
  end

  # Test Server Mock Tracking Numbers
  # https://www.fedex.com/us/developer/webhelp/ws/2019/US/wsdvg/Appendix_F_Test_Server_Mock_Tracking_Numbers.htm

  def test_track_service
    service = FedexApi::Service::Track.new
    reply = service.track('403934084723025', '122816215025810')

    assert reply.success?
    assert_equal 2, reply.tracking_details.size
    assert_equal 'Delivered', reply.tracking_details_for('122816215025810')[:status_detail][:description]
  end
end
