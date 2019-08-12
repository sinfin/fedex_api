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
    service.add_package(weight: 1)
    response = service.get_rates
    assert 'SUCCESS', response.body[:rate_reply][:highest_severity]
  end

  def test_ship_service
    service = FedexApi::Service::Ship.new
    service.shipper = @shipper
    service.recipient = @recipient
    service.add_package(weight: 1)
    response = service.process_shipment
    assert 'SUCCESS', response.body[:process_shipment_reply][:highest_severity]
  end

  def test_track_service
    service = FedexApi::Service::Track.new
    response = service.track('403934084723025', '122816215025810')
    assert 'SUCCESS', response.body[:track_reply][:highest_severity] != "SUCCESS"
  end
end
